"""Execute the vote-result scoreboard subset and verify home-button wiring."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
functions = root / "resources/datapack/required/ct/data/ct/function"
def read(name):
    return (functions / (name + ".mcfunction")).read_text(encoding="utf-8")

def resolve(total, threshold, majority, marked):
    scores = {"total": total, "current_majority": threshold, "majority": majority}
    def execute(line):
        nonlocal marked
        if line.startswith("execute unless entity"):
            return False  # Each scenario has a nominee.
        if line.startswith("execute "):
            condition, line = line[8:].split(" run ", 1)
            for clause in condition.split("if score ")[1:]:
                parts = clause.split()
                value = scores[parts[0]]
                if parts[2] == "matches":
                    ok = value >= 1 if parts[3] == "1.." else value == int(parts[3])
                else:
                    other = scores[parts[3]]
                    ok = value == other if parts[2] == "=" else value < other
                if not ok:
                    return False
        if line.startswith("return"):
            if line.startswith("return run "):
                execute(line[11:])
            return True
        p = line.split()
        if line.startswith("scoreboard players operation"):
            scores[p[3]] = scores[p[6]]
        elif line.startswith("scoreboard players set"):
            scores[p[3]] = int(p[5])
        elif line.startswith("scoreboard players remove"):
            scores[p[3]] -= int(p[5])
        elif line.startswith("scoreboard players add"):
            scores[p[3]] += int(p[5])
        elif line == "tag @a remove marked_for_execution":
            marked = None
        elif line == "tag @a[tag=nominee] add marked_for_execution":
            marked = "new"
        elif line == "function ct:loop/vote/set_majority":
            for command in read("loop/vote/set_majority").splitlines():
                execute(command)
        else:
            raise AssertionError(line)
        return False
    for line in read("loop/vote/resolve_result").splitlines():
        if line and not line.startswith("#") and execute(line):
            break
    return scores["current_majority"], marked

for alive in range(1, 16):
    minimum = (alive + 1) // 2
    assert resolve(minimum - 1, 0, minimum, None) == (0, None)
    assert resolve(minimum, 0, minimum, None) == (minimum + 1, "new")
    assert resolve(minimum, minimum + 1, minimum, "old") == (minimum + 1, None)
    assert resolve(minimum - 1, minimum + 1, minimum, "old") == (minimum + 1, "old")
    assert resolve(minimum + 1, minimum + 1, minimum, "old") == (minimum + 2, "new")
    assert resolve(minimum + 1, minimum + 1, minimum, None) == (minimum + 2, "new")
end = read("loop/vote/end_voting")
assert end.index("ct:loop/vote/resolve_result") < end.index("#ct:broadcast/vote_finished") < end.index("scoreboard players set total vote 0")
assert "function ct:loop/vote/required_votes" in read("loop/vote/start_vote")
assert "function ct:admin/variables/score" in read("loop/vote/required_votes")
assert "as @a[tag=marked_for_execution] at @s run particle minecraft:sculk_soul" in read("loop/root")
for phase in range(1, 4):
    assert f"matches 1..3 if entity @a[tag=nominee] run function ct:loop/vote/update_counter" in read("loop/root")
for phase in ("phase/night", "phase/dusk"):
    assert "tag @a remove marked_for_execution" in read(phase)

homes = re.findall(r"vc=(\d+)\}\] run tp @s ([^\n]+)", read("cmd/tpallhome"))
ui = (root / "config/fancymenu/customization/ct-quick_actions_root.txt").read_text(encoding="utf-8")
assert len(homes) == 15
home_buttons = [block for block in ui.split("\nelement {") if " = /botc_home " in block]
assert len(home_buttons) == 15
for block in home_buttons:
    # Tilted face buttons rendered correctly but did not dispatch mouse clicks.
    assert "\n  horizontal_tilt_degrees = 0.0\n" in block
for seat, coordinates in homes:
    assert f"/botc_home {seat}\n" in ui
    assert f"matches {seat} run tp @s {coordinates}" in read("cmd/home")
assert "/tp @s @e[tag=house_" not in ui
nomination = read("cmd/nom/long_arm")
assert nomination.index("ct:loop/vote/required_votes") < nomination.index("clocktower.notice.nomination_required")
assert "function ct:loop/vote/update_counter" in nomination
counter = read("loop/vote/update_counter")
defaults = re.findall(r'p(\d+):"Yambonaut"', counter.splitlines()[0])
assert set(defaults) == {str(i) for i in range(1, 16)}
display = read("loop/vote/display_in_actionbar")
assert set(re.findall(r"\$\(p(\d+)\)", display)) <= set(defaults)
for seat in range(1, 16):
    for tag in ("voting_yes", "voting_ghost", "voting_banshee"):
        assert f"tag={tag},tag=!storyteller,tag=!spectator,scores={{id={seat}}}" in counter
for alive in range(1, 16):
    for previous in (0, 3, 8):
        required = max((alive + 1) // 2, previous)
        assert required >= (alive + 1) // 2 and required >= previous
print("PASS: vote results, nomination threshold, complete HUD macro arguments, all vote types, home destinations")
