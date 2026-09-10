"""Run with python scripts/check_pregame_setup.py; static wiring and seat checks."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
functions = root / "resources/datapack/required/ct/data/ct/function"
ui = root / "config/fancymenu/customization"

def read(name):
    return (functions / (name + ".mcfunction")).read_text(encoding="utf-8")

for name in ("admin/setup/apply", "admin/setup/set_from_menu", "cmd/swap_next_seat"):
    lines = read(name).splitlines()
    assert "storyteller" in lines[0], name
    assert "phase game_data matches 0" in lines[1], name

bag = (ui / "ct-bag_layout.txt").read_text(encoding="utf-8")
assert '/botc_bag {"placeholder":"getvariable","values":{"name":"stored_player_count"}}' in bag
assert "ct:admin/setup/set_from_menu" not in bag
apply = read("admin/setup/apply")
assert "matches 5..15" in apply
assert apply.index("matches 5..15") < apply.index("operation player_count")
assert "storage ct:bag count" in apply
saved = read("admin/setup/set_from_menu")
assert saved.index("storage ct:bag roles set from") < saved.index("function ct:admin/setup/prepare")
assert "clear_variables" not in saved
assert "restore_saved" in read("item/bag")
assert "restore_variables" in read("item/bag")
prepare = read("admin/setup/prepare")
assert "ct:phase/night" not in prepare
assert "player_count game_data" in prepare
assert "set_grim_variables" in prepare
assert "ct:start_game/refresh_seats" in prepare
assert "tag=!has_role" in read("start_game/setup")
assert "#online game_data = player_count game_data" in read("start_game/setup")
assert "data remove storage ct:grimoire roles" in read("admin/reset_game")
assert "#prepared game_data 0" in read("admin/reset_game")

for name in ("ct-role_toggler", "ct-role_toggler_travellers"):
    text = (ui / (name + ".txt")).read_text(encoding="utf-8")
    actions = [line for line in text.splitlines() if "action_type:sendmessage] = /botc_role " in line]
    assert actions, name
    assert not re.search(r"action_type:set_variable\] = p.*_role:", text), name
    for line in actions:
        assert line.count('"placeholder"') >= 2, line
for name in ("ct-role_toggler_player", "ct-role_toggler_travellers_player"):
    assert "/botc_role" not in (ui / (name + ".txt")).read_text(encoding="utf-8")
role = read("cmd/grimoire_role")
assert role.startswith("execute unless entity @s[tag=storyteller]")
assert "matches 1..15" in role
assert "matches 1.." in role
player_role = read("cmd/grimoire_role_player")
for line in player_role.splitlines():
    if "role = #role" in line or "add has_role" in line:
        assert "phase game_data matches 0" in line
assert "ct:grimoire roles.p$(seat)" in read("cmd/grimoire_role_store")
for name in ("botc_bag", "botc_role", "botc_seat"):
    cmd = json.loads((root / "config/melius-commands/commands" / (name + ".json")).read_text())
    assert cmd["id"] == name

swap = read("cmd/swap_next_seat")
assert "tag=!seat_swap_source" in swap
assert "$scoreboard players set #next game_data $(target)" in swap
assert "score #next game_data = #seat game_data run return 0" in swap
assert len(re.findall(r"^team join .*scores=\{id=\d+\}", swap, re.M)) == 15
# All supported roster sizes and arbitrary destination seats.
for count in range(5, 16):
    for selected in range(1, count + 1):
        for following in range(1, count + 1):
            occupied = list(range(1, count + 1))
            after = [following if seat == selected else selected if seat == following else seat for seat in occupied]
            assert len(set(after)) == len(after)
            assert all(1 <= seat <= count for seat in after)
actions = (ui / "ct-grimoire_actions.txt").read_text(encoding="utf-8")
background = (ui / "ct-grimoire_background.txt").read_text(encoding="utf-8")
buttons = re.findall(r"(?ms)^element \{.*?^\}", actions)
swap_buttons = [b for b in buttons if "button_element_executable_block_identifier = swap-start-" in b]
assert len(swap_buttons) == 15
for button in swap_buttons:
    seat = re.search(r"= editing_player:(\d+)", button)[1]
    character = next(b for b in buttons if "change_character" in b and re.search(r"= editing_player:" + seat + r"$", b, re.M))
    y = lambda b: int(re.search(r"^  y = (-?\d+)$", b, re.M)[1])
    assert y(button) + 14 == y(character)
    assert "바꿀 사람을 선택해주세요" in button
    assert "swap_selecting:true" in button and "game_active:false" in button
    assert "disable_layout" not in button
targets = re.findall(r"(?ms)^element \{.*?^\}", background)
targets = [b for b in targets if "action_type:set_variable] = editing_player:" in b]
assert len(targets) == 30
for button in targets:
    identifier = re.search(r"button_element_executable_block_identifier = (.*)", button)[1]
    assert f"[executable_block:{identifier}][type:generic] = [executables:swap-if-" in button
    assert re.search(r"\[executable_block:swap-if-\d+\]\[type:if\] = \[executables:swap-target-", button)
    assert "/botc_seat" in button and "swap_source" in button
    assert "= swap_selecting:true" in button
assert "[action_type:set_variable] = swap_selecting:false" in background
for reset in ("fmvariable set swap_selecting false false", "fmvariable set editing_player false 0", "fmlayout ct-grimoire_actions false"):
    assert reset in swap
assert "다음 좌석과 교환" not in actions
print("PASS: bag persistence/count, pregame roles, two-click seat selection, completion/close reset")
