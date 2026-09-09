"""Regression checks for pyre target selection and position handling."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
functions = root / "resources/datapack/required/ct/data/ct/function"
pyre = (functions / "kill/execute/light_pyre.mcfunction").read_text()
command = (functions / "cmd/pyre.mcfunction").read_text()

pyre_guard = "execute unless entity @s[x=125,y=72,z=63,dx=2,dy=2,dz=2] run tp @s 126 73 64"
command_guard = "$execute as $(player) unless entity @s[x=125,y=72,z=63,dx=2,dy=2,dz=2] run tp @s 126 73 64"

assert pyre_guard in pyre
assert "tag @s add being_executed" in pyre
assert "@a[tag=marked_for_execution]" not in pyre
assert command_guard in command
assert "ct:error/not_storyteller" in command
assert "ct:error/game_not_active" in command
print("Pyre target check: PASS (selected player only; players already on the pyre are not teleported again)")

execution = (functions / "kill/execute/execute.mcfunction").read_text()
assert execution.count("execute if entity @s[tag=!dead] run function ct:kill/die") == 1
assert execution.index("tag @s remove marked_for_execution") < execution.index("run function ct:kill/die")
print("Execution death check: PASS (existing dead players skip duplicate death)")
