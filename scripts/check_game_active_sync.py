"""Run with python scripts/check_game_active_sync.py; no Minecraft required."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
functions = root / "resources/datapack/required/ct/data/ct/function"
sync = (functions / "util/sync_variables.mcfunction").read_text(encoding="utf-8")
rules = re.findall(
    r"^execute if score phase game_data matches (0|1\.\.) as @a "
    r"run fmvariable set game_active false (true|false)$", sync, re.MULTILINE
)
assert len(rules) == 2, "Both lobby and active phases must synchronize game_active"
for phase in range(5):
    for previous in (None, "false", "true"):
        value = previous
        for interval, replacement in rules:
            if (interval == "0" and phase == 0) or (interval == "1.." and phase >= 1):
                value = replacement
        assert value == ("false" if phase == 0 else "true"), (phase, previous, value)

for filename in ("admin/setup/set_from_menu", "admin/reset_game", "loop/player/join_game", "start_game/setup"):
    text = (functions / (filename + ".mcfunction")).read_text(encoding="utf-8")
    assert "function ct:util/sync_variables" in text, filename
print("Game-active synchronization check: PASS (missing/stale state, phases 0-4)")
