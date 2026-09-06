"""Run with python scripts/check_ui_empty_state.py; no Minecraft required."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
layouts = root / "config/fancymenu/customization"
checked = 0
for path in layouts.glob("*.txt"):
    text = path.read_text(encoding="utf-8")
    assert not re.search(r"night_order\.(first|other)\[\{id:", text), path
    for line in text.splitlines():
        match = re.fullmatch(
            r"  [a-z_]+ = "
            r"\[source:location\]ct:textures/(role|script)/(.+)\.png", line
        )
        if not match or '{"placeholder"' not in match[2]:
            continue
        kind, expression = match.groups()
        cases = ":none,faded/:faded/none" if kind == "role" else ":custom_script"
        prefix = '{"placeholder":"switch_case","values":{"value":"'
        separator = '","cases":"' + cases + '","default":"'
        assert expression.startswith(prefix) and separator in expression, (path, line)
        value, default = expression[len(prefix):].rsplit(separator, 1)
        assert default == value + '"}}', (path, line)
        # FancyMenu splits cases by comma and colon; empty keys are intentional.
        mapping = dict(case.split(":") for case in cases.split(","))
        for empty in (["", "faded/"] if kind == "role" else [""]):
            asset = root / "resources/resourcepack/required/Blood on the Clocktower/assets/ct/textures" / kind / (mapping[empty] + ".png")
            assert asset.is_file(), asset
        assert mapping.get("washerwoman", "washerwoman") == "washerwoman"
        checked += 1
assert checked > 0
print(f"UI empty-state check: PASS ({checked} guarded image references)")
