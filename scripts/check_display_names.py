"""Check display-only menu boundaries; run with python scripts/check_display_names.py."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
layouts = root / "config/fancymenu/customization"
references = 0
for path in layouts.glob("*.txt"):
    for line in path.read_text(encoding="utf-8").splitlines():
        if '"placeholder":"display_name"' not in line:
            continue
        assert re.match(r"  (source|description|buttonlabel) = ", line), (path, line)
        assert "[source:" not in line and "[action_type:" not in line, (path, line)
        assert line.count("{") == line.count("}"), (path, line)
        references += line.count('"placeholder":"display_name"')
assert references >= 150, references

# The same account identifier must still drive actions and skin requests.
nominee = (layouts / "ct-noms_nominee.txt").read_text(encoding="utf-8")
account = '{"placeholder":"getvariable","values":{"name":"player_1"}}'
assert "= /set_nominee " + account in nominee
assert "https://minotar.net/helm/" + account + "/100.png" in nominee
functions = root / "resources/datapack/required/ct/data/ct/function"
assert "$tag $(current_nominee) add marked_for_execution" in (functions / "kill/execute/mark.mcfunction").read_text()
assert "$fmvariable set player_1 false $(p1)" in (functions / "start_game/roles/set_grim_variables.mcfunction").read_text()
for name in ("cmd/whisper", "point/point"):
    text = (functions / (name + ".mcfunction")).read_text(encoding="utf-8")
    assert not re.search(r'\btext"?:"?\$\((player|target|pointer)\)', text), name
    assert 'selector:"@a[name=' in text or '"selector":"@a[name=' in text, name
print(f"Display-name boundaries: PASS ({references} display references; account actions preserved)")
