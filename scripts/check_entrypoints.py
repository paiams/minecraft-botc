"""Run on Windows: python scripts/check_entrypoints.py. Never starts real services or releases."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]


def run(script, arguments="", cwd=None, input_text="\n"):
    command = os.environ.get("ComSpec", "cmd.exe")
    return subprocess.run(
        f'"{command}" /d /s /c ""{script}" {arguments}"',
        cwd=cwd, input=input_text, capture_output=True, text=True, encoding="utf-8",
        errors="replace", timeout=30,
    )


with tempfile.TemporaryDirectory(prefix="botc entrypoints ") as temporary:
    directory = Path(temporary)
    release = directory / "release.bat"
    shutil.copy2(ROOT.parent / "botc-launcher/release.bat", release)
    scripts = directory / "scripts"
    scripts.mkdir()
    for target, code in (("game", 0), ("launcher", 7)):
        (scripts / f"release_{target}.ps1").write_text(
            f"Write-Output 'TARGET:{target}'\n"
            "Write-Output ('ARGS:' + (ConvertTo-Json -InputObject @($args) -Compress))\n"
            f"exit {code}\n", encoding="utf-8",
        )
        result = run(release, f'{target} -NoDeploy -ReleaseNotes "UI & spaces!" '
                     '-One 1 -Two 2 -Three 3 -Four 4', directory)
        assert result.returncode == code, result.stdout + result.stderr
        assert f"TARGET:{target}" in result.stdout, result.stdout
        received = next(line[5:] for line in result.stdout.splitlines() if line.startswith("ARGS:"))
        assert json.loads(received) == [
            "-NoDeploy", "-ReleaseNotes", "UI & spaces!",
            "-One", "1", "-Two", "2", "-Three", "3", "-Four", "4",
        ], received
    for script in (ROOT / "start.cmd", release):
        assert run(script, "--help", directory).returncode == 0
        assert run(script, "unknown", directory).returncode == 2
    for selection, target, code in (("1", "game", 0), ("2", "launcher", 7), ("Q", None, 0)):
        result = run(release, cwd=directory, input_text=selection + "\n")
        assert result.returncode == code, result.stdout + result.stderr
        assert (f"TARGET:{target}" in result.stdout if target else "TARGET:" not in result.stdout)

    # Exercise actual manager compilation and validation with inert fixture files.
    pack = directory / "minecraft-botc"
    (pack / "scripts").mkdir(parents=True)
    (pack / "server").mkdir()
    broadcast = directory / "minecraft-botc-broadcast"
    broadcast.mkdir()
    shutil.copy2(ROOT / "start.cmd", pack / "start.cmd")
    shutil.copy2(ROOT / "scripts/BotcStack.java", pack / "scripts/BotcStack.java")
    (pack / "server/fabric-server-launch.jar").touch()
    (broadcast / "gradlew.bat").write_text("@exit /b 0\n")
    result = run(pack / "start.cmd", "--check", directory)
    assert result.returncode == 0, result.stdout + result.stderr
    (broadcast / "gradlew.bat").write_text('@echo off\necho DEMO:%*\nexit /b 9\n')
    result = run(pack / "start.cmd", "demo --managed", directory)
    assert result.returncode == 9 and "demo -Pport=8770" in result.stdout, result
    (broadcast / "gradlew.bat").unlink()
    result = run(pack / "start.cmd", "--check", directory)
    assert result.returncode != 0 and "Missing required file" in result.stderr, result

print("Entry point checks passed; no services started or releases published.")
