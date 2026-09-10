"""Static wiring checks; runtime verification is still required."""
import json
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
print('PASS: guarded test setup, real vote path, input ranges and cancellation')
