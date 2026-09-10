execute unless entity @s[tag=storyteller] run return 0
execute if entity @a[tag=!storyteller,tag=!botc_test] run return run tellraw @s {text:"다른 실제 참가자가 접속해 있어 테스트를 중단합니다.",color:"red"}
execute if score #test_busy game_data matches 1 run return run tellraw @s {text:"자동 진행 중입니다. 완료 후 다시 선택하세요.",color:"yellow"}
execute if entity @a[tag=storyteller,limit=2] run scoreboard players set #test_people game_data 0
execute as @a[tag=!botc_test] run scoreboard players add #test_people game_data 1
execute unless score #test_people game_data matches 1 run return run tellraw @s {text:"실제 접속자가 한 명일 때만 준비할 수 있습니다.",color:"red"}
function ct:admin/reset_game
tag @s add botc_test_controller
scoreboard players set #test_active game_data 1
scoreboard players set #test_busy game_data 1
execute unless entity @a[name=Alex] run player Alex spawn
execute unless entity @a[name=Steve] run player Steve spawn
execute unless entity @a[name=Ari] run player Ari spawn
execute unless entity @a[name=efe] run player efe spawn
execute unless entity @a[name=Kai] run player Kai spawn
execute unless entity @a[name=Makena] run player Makena spawn
execute unless entity @a[name=Emma] run player Emma spawn
execute unless entity @a[name=Sunny] run player Sunny spawn
schedule function botc_test:ready 3s replace
tellraw @s {text:"가상 참가자 8명을 접속시키는 중입니다...",color:"yellow"}
