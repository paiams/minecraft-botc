"""Run the built mod in a disposable server with two Carpet players.

Requires Java 21 and the pinned dependencies prepared in ../../server.
Uses a new directory under build/; never replaces an existing runtime/world.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import queue
import shutil
import socket
import subprocess
import tempfile
import threading
import time
import uuid

extension = Path(__file__).resolve().parent
root = extension.parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--java", default="java")
args = parser.parse_args()
source = root / "server"
assert "eula=true" in (source / "eula.txt").read_text(), "Accept the Minecraft EULA in the prepared server first."
runtime = Path(tempfile.mkdtemp(prefix="smoke-", dir=extension / "build"))
socket_directory = Path.home() / ".cache/botc-java-sockets"
socket_directory.mkdir(parents=True, exist_ok=True)
for directory in ("mods", "libraries", "versions"):
    shutil.copytree(source / directory, runtime / directory, copy_function=os.link,
                    ignore=shutil.ignore_patterns("*.disabled"))
shutil.copy2(source / "fabric-server-launch.jar", runtime)
shutil.copy2(extension / "build/libs/botc-display-names-1.0.0.jar", runtime / "mods")
shutil.copytree(root / "config/melius-commands", runtime / "config/melius-commands")
pack = runtime / "world/datapacks/name-check"
pack.mkdir(parents=True)
shutil.copy2(root / "resources/datapack/required/ct/pack.mcmeta", pack)
shutil.copytree(root / "resources/datapack/required/ct/data/ct", pack / "data/ct")
# Functions are loaded, but no game tick/load tags run in this empty test world.
(runtime / "eula.txt").write_text("eula=true\n")
# Synthetic offline profiles keep the check independent of Mojang name lookups.
(runtime / "usercache.json").write_text(json.dumps([
    {"name": name, "uuid": str(uuid.UUID(bytes=hashlib.md5(("OfflinePlayer:" + name).encode()).digest(), version=3)),
     "expiresOn": "2099-01-01 00:00:00 +0000"}
    for name in ("botcnametesta", "botcnametestb")
]), encoding="utf-8")
with socket.socket() as probe:
    probe.bind(("127.0.0.1", 0))
    port = probe.getsockname()[1]
(runtime / "server.properties").write_text(
    f"server-ip=127.0.0.1\nserver-port={port}\nonline-mode=false\nlevel-type=minecraft:flat\n"
    "spawn-protection=0\nview-distance=2\nsimulation-distance=2\nmax-tick-time=0\n"
    'generator-settings={"layers":[{"block":"minecraft:bedrock","height":1},{"block":"minecraft:stone","height":2}],"biome":"minecraft:plains"}\n'
    "generate-structures=false\n", encoding="utf-8")
(runtime / "config/voicechat").mkdir(parents=True, exist_ok=True)
(runtime / "config/voicechat/voicechat-server.properties").write_text("port=0\nbind_address=127.0.0.1\n")
events = queue.Queue()
transcript = []

def read_output(process):
    for line in process.stdout:
        transcript.append(line)
        events.put(line)

def wait_for(text, timeout=45):
    end = time.monotonic() + timeout
    while time.monotonic() < end:
        try:
            line = events.get(timeout=1)
        except queue.Empty:
            if process.poll() is not None:
                raise AssertionError(f"Server exited {process.returncode}; expected {text}")
            continue
        if text in line:
            return line
    raise AssertionError(f"Timed out waiting for {text}")

def command(text):
    if " run point " in text:
        time.sleep(1.1)  # Respect the pack's existing one-second pointing cooldown.
    process.stdin.write(text + "\n")
    process.stdin.flush()

try:
    for attempt in range(2):
        process = subprocess.Popen([args.java, "-Xmx1G", "-Dfile.encoding=UTF-8",
                                    f"-Djdk.net.unixdomain.tmpdir={socket_directory}", "-jar", "fabric-server-launch.jar", "nogui"],
                                   cwd=runtime, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, text=True, encoding="utf-8", errors="replace")
        threading.Thread(target=read_output, args=(process,), daemon=True).start()
        wait_for('Done (', 180)
        assert not any("Failed to load function ct:" in line for line in transcript), "BotC function failed to load"
        command("player botcnametesta spawn at 0 65 0")
        wait_for("botcnametesta[local] logged in")
        command("player botcnametestb spawn at 2 65 0")
        wait_for("botcnametestb[local] logged in")
        if attempt == 0:
            command("displayname setfor botcnametesta Élodie")
            wait_for("Display name for botcnametesta: Élodie")
            command("displayname setfor botcnametestb 山田太郎")
            wait_for("Display name for botcnametestb: 山田太郎")
            command("displayname setfor botcnametestb ÉLODIE")
            wait_for("already used by another player")
        command('execute as Élodie run say DISPLAY_NAME_TARGET_OK')
        wait_for("DISPLAY_NAME_TARGET_OK")
        command('execute as 山田太郎 run say MULTILINGUAL_TARGET_OK')
        wait_for("MULTILINGUAL_TARGET_OK")
        command("scoreboard objectives add id dummy")
        command("scoreboard objectives add pointing_at dummy")
        command("scoreboard objectives add neighbor_check dummy")
        command("scoreboard objectives add game_data dummy")
        command("scoreboard players set botcnametesta id 1")
        command("scoreboard players set botcnametestb id 2")
        command("scoreboard players set phase game_data 1")
        command("scoreboard players set player_count game_data 15")
        command("scoreboard players set botcnametesta pointing_at 0")
        command("execute as botcnametesta run point 山田太郎")
        command("execute if score botcnametesta pointing_at matches 2 run say POINT_ACCOUNT_OK")
        wait_for("POINT_ACCOUNT_OK")
        command("scoreboard players set botcnametesta pointing_at 0")
        command("execute as botcnametesta run point @a[name=botcnametestb]")
        command("execute if score botcnametesta pointing_at matches 2 run say SELECTOR_ACCOUNT_OK")
        wait_for("SELECTOR_ACCOUNT_OK")
        command("scoreboard players set botcnametesta neighbor_check 0")
        command("execute as botcnametesta run whisper 山田太郎 Hello")
        command("execute if score botcnametesta neighbor_check matches -1 run say WHISPER_ACCOUNT_OK")
        wait_for("WHISPER_ACCOUNT_OK")
        command("scoreboard players set botcnametestb id 7")
        command("execute as botcnametesta run whisper 山田太郎 Not a neighbor")
        command("execute if score botcnametesta neighbor_check matches -6 run say NON_NEIGHBOR_CHECK_OK")
        wait_for("NON_NEIGHBOR_CHECK_OK")
        command("scoreboard players set botcnametestb id 2")
        command("tag botcnametesta add storyteller")
        command("execute as botcnametesta run set_nominee 山田太郎")
        command("execute if entity @a[name=botcnametestb,tag=nominee] run say NOMINEE_ACCOUNT_OK")
        wait_for("NOMINEE_ACCOUNT_OK")
        command("execute as botcnametesta run set_nominator Élodie")
        command("execute if entity @a[name=botcnametesta,tag=nominator] run say NOMINATOR_ACCOUNT_OK")
        wait_for("NOMINATOR_ACCOUNT_OK")
        command("tag botcnametesta remove storyteller")
        command("setblock 0 65 0 minecraft:oak_sign")
        command('data modify block 0 65 0 front_text.messages[0] set value {selector:"@a[name=botcnametesta]"}')
        command("data get block 0 65 0 front_text.messages[0]")
        sign = wait_for("has the following block data")
        assert "Élodie" in sign and "botcnametesta" in sign, sign
        if attempt == 1:
            command('displayname setfor botcnametestb João Silva')
            wait_for('Display name for botcnametestb: João Silva')
            command("scoreboard players set botcnametesta pointing_at 0")
            command('execute as botcnametesta run point "João Silva"')
            command("execute if score botcnametesta pointing_at matches 2 run say SPACED_NAME_OK")
            wait_for("SPACED_NAME_OK")
            command("displayname resetfor botcnametesta")
            wait_for("Display name for botcnametesta: botcnametesta")
        command("stop")
        process.wait(timeout=60)
        assert process.returncode == 0, process.returncode
    entries = json.loads((runtime / "world/data/botc-display-names.json").read_text(encoding="utf-8"))
    assert any(e["accountName"] == "botcnametesta" and e["displayName"] == "" for e in entries), entries
    assert any(e["accountName"] == "botcnametestb" and e["displayName"] == "João Silva" for e in entries), entries
    print(f"Display-name server smoke: PASS; logs: {runtime}")
finally:
    if "process" in globals() and process.poll() is None:
        command("stop")
        try:
            process.wait(timeout=60)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
    (runtime / "smoke.log").write_text("".join(transcript), encoding="utf-8")
    print(f"Smoke log: {runtime / 'smoke.log'}")
