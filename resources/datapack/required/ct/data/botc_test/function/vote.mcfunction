execute unless entity @s[tag=storyteller] run return 0
execute if entity @a[tag=!storyteller,tag=!botc_test] run return run tellraw @s {text:"다른 실제 참가자가 접속해 있어 테스트를 중단합니다.",color:"red"}
execute unless score #test_active game_data matches 1 run return run tellraw @s {text:"먼저 /botc_test setup 으로 8인 테스트를 준비하세요.",color:"red"}
execute if score #test_busy game_data matches 1 run return run tellraw @s {text:"자동 진행 중입니다. 완료 후 다시 선택하세요.",color:"yellow"}
execute unless score phase game_data matches 1..3 run return run tellraw @s {text:"먼저 첫날 낮까지 진행하세요.",color:"red"}
execute if entity @a[tag=nominee] run return run tellraw @s {text:"기존 지목/투표를 마친 후 실행하세요.",color:"red"}
$scoreboard players set #test_yes game_data $(yes)
$scoreboard players set #test_target game_data $(seat)
execute unless score #test_yes game_data matches 0..8 run return 0
execute unless score #test_target game_data matches 1..8 run return 0
scoreboard players set #test_count game_data 0
execute as @a[tag=botc_test,tag=!dead] run scoreboard players add #test_count game_data 1
execute unless score #test_count game_data matches 8 run return run tellraw @s {text:"이 시나리오는 생존 가상 참가자 8명이 필요합니다. 8인 준비를 다시 실행하세요.",color:"red"}
scoreboard players set #test_busy game_data 1
function ct:cmd/nom/set_nominator {p:"@a[tag=botc_test,scores={id=8},limit=1]"}
$function ct:cmd/nom/set_nominee {p:"@a[tag=botc_test,scores={id=$(seat)},limit=1]"}
execute unless entity @a[tag=nominee] run return run scoreboard players set #test_busy game_data 0
execute as @a[tag=botc_test] if score @s id <= #test_yes game_data run function ct:item/vote_no
tellraw @s {text:"상단 HUD를 확인하세요. 4초 뒤 정상 투표 순서로 자동 집계합니다.",color:"yellow"}
schedule function botc_test:vote_start 4s replace
