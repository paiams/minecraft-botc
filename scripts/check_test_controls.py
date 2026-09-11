"""Static wiring checks; runtime verification is still required."""
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
base = root / 'resources/datapack/required/ct/data/botc_test/function'
read = lambda name: (base / f'{name}.mcfunction').read_text(encoding='utf-8')
command = json.loads((root / 'config/melius-commands/commands/botc_test.json').read_text())
assert {item['id'] for item in command['literals']} == {'setup', 'day', 'vote', 'stop'}
for name in ('setup', 'day', 'vote', 'stop'):
    assert 'unless entity @s[tag=storyteller]' in read(name)
    assert 'tag=!storyteller,tag=!botc_test' in read(name)
assert 'function ct:admin/reset_game' not in read('confirm')
assert read('setup').count(' run player ') == 8
for name in ('setup', 'ready', 'stop'):
    assert 'name=Efe' not in read(name)
    assert 'name=efe' in read(name)  # Mojang returns this account in lowercase.
assert 'schedule function botc_test:ready 3s replace' in read('setup')
assert 'function ct:admin/setup/prepare' in read('ready')
assert 'function ct:item/vote_no' in read('vote')
assert 'matches 0..8' in read('vote') and 'matches 1..8' in read('vote')
assert 'function ct:loop/vote/start_vote' in read('vote_start')
assert 'ct:loop/vote/resolve_result' not in read('vote')  # Never fake the result.
for task in ('ready', 'day_ready', 'vote_start', 'vote_done'):
    assert f'schedule clear botc_test:{task}' in read('stop')
assert read('stop').count('tag=botc_test] run player ') == 8

quick_actions = (root / 'config/fancymenu/customization/ct-quick_actions_root.txt').read_text(encoding='utf-8')
quick_lines = quick_actions.splitlines()
home_faces = []
for index, line in enumerate(quick_lines):
    command_match = re.search(r'/botc_home (\d+)', line)
    if not command_match:
        continue
    block = '\n'.join(quick_lines[index:index + 90])
    face_match = re.search(r'backgroundnormal = .*?player_(\d+)', block)
    assert face_match, f'missing player face after {line.strip()}'
    command_seat = int(command_match.group(1))
    face_seat = int(face_match.group(1))
    assert command_seat == face_seat, f'home button player_{face_seat} targets seat {command_seat}'
    assert f'[req_id:home-face-ready-{face_seat}] = home_faces_ready:true' in block
    home_faces.append(face_seat)
assert sorted(home_faces) == list(range(1, 16)), home_faces

reset_player = (root / 'resources/datapack/required/ct/data/ct/function/util/reset_player.mcfunction').read_text(encoding='utf-8')
grim_variables = (root / 'resources/datapack/required/ct/data/ct/function/start_game/roles/set_grim_variables.mcfunction').read_text(encoding='utf-8')
sync_variables = (root / 'resources/datapack/required/ct/data/ct/function/util/sync_variables.mcfunction').read_text(encoding='utf-8')
assert reset_player.index('home_faces_ready false false') < reset_player.index('player_1 false Nobody!')
assert grim_variables.splitlines()[0] == '$fmvariable set home_faces_ready false false'
assert grim_variables.splitlines()[-1] == '$fmvariable set home_faces_ready false true'
assert 'function ct:start_game/roles/set_grim_variables with storage ct:players players' in sync_variables

print('PASS: guarded test setup, real vote path, input ranges and cancellation')
