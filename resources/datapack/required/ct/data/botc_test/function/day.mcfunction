execute unless entity @s[tag=storyteller] run return 0
execute if entity @a[tag=!storyteller,tag=!botc_test] run return run tellraw @s {text:"다른 실제 참가자가 접속해 있어 테스트를 중단합니다.",color:"red"}
execute unless score #test_active game_data matches 1 run return run tellraw @s {text:"먼저 /botc_test setup 으로 8인 테스트를 준비하세요.",color:"red"}
execute if score #test_busy game_data matches 1 run return run tellraw @s {text:"자동 진행 중입니다. 완료 후 다시 선택하세요.",color:"yellow"}
execute unless score phase game_data matches 0 run return run tellraw @s {text:"이미 게임이 시작됐습니다. 투표 버튼을 사용하거나 8인 준비를 다시 실행하세요.",color:"yellow"}
function ct:start_game/setup
execute unless score phase game_data matches 4 run return 0
scoreboard players set #test_busy game_data 1
schedule function botc_test:day_ready 3s replace
