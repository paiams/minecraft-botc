"""Regression check: the selected player, not the marked player, enters the pyre."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
functions = root / "resources/datapack/required/ct/data/ct/function"
pyre = (functions / "kill/execute/light_pyre.mcfunction").read_text()
command = (functions / "cmd/pyre.mcfunction").read_text()
assert "tp @s 126 73 64" in pyre
assert "tag @s add being_executed" in pyre
assert "@a[tag=marked_for_execution]" not in pyre
assert "$execute as $(player)" in command and "run tp @s 126 73 64" in command
assert "ct:error/not_storyteller" in command
assert "ct:error/game_not_active" in command
print("Pyre target check: PASS")
