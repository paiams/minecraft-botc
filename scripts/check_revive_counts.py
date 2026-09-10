"""Run with python scripts/check_revive_counts.py; no Minecraft required."""
from pathlib import Path
import re

functions = Path(__file__).resolve().parents[1] / "resources/datapack/required/ct/data/ct/function"
revive = (functions / "kill/revive.mcfunction").read_text(encoding="utf-8")
counter = (functions / "admin/variables/score.mcfunction").read_text(encoding="utf-8")
assert revive.index("tag @s remove dead") < revive.index("function ct:admin/variables/score")
assert revive.index("function ct:admin/variables/score") < revive.index("function ct:util/sync_variables")

def recount(players):
    scores = {}
    for line in counter.splitlines():
        reset = re.fullmatch(r"scoreboard players set (\w+) game_data 0", line)
        if reset:
            scores[reset[1]] = 0
            continue
        rule = re.fullmatch(r"execute as @a\[(.*)\] run scoreboard players add (\w+) game_data 1", line)
        assert rule, line
        tags = [part.removeprefix("tag=") for part in rule[1].split(",")]
        scores[rule[2]] += sum(all(
            tag[1:] not in player if tag.startswith("!") else tag in player
            for tag in tags
        ) for player in players)
    return scores

for spent in (False, True):
    target = {"dead"} | ({"expended_ghost"} if spent else set())
    players = [target, {"dead"}, {"dead", "expended_ghost"}, set(), {"storyteller"}]
    assert recount(players)["ghost_votes"] == (1 if spent else 2)
    for repeat in range(2):
        for line in revive.splitlines():
            if line.startswith("tag @s remove "):
                target.discard(line.split()[-1])
            elif line == "function ct:admin/variables/score":
                scores = recount(players)
            elif line == "function ct:util/sync_variables":
                assert scores == {"ghost_votes": 1, "alive_players": 2}
    target.add("dead")
    assert recount(players) == {"ghost_votes": 2, "alive_players": 1}
print("PASS: revive refreshes ghost/alive counts before UI sync; spent, repeated revival and re-death")
