execute unless entity @s[tag=storyteller] run return 0
execute if entity @a[tag=!storyteller,tag=!botc_test] run return run tellraw @s {text:"다른 실제 참가자가 접속해 있어 테스트를 중단합니다.",color:"red"}
execute unless score #test_active game_data matches 1 run return run tellraw @s {text:"먼저 /botc_test setup 으로 8인 테스트를 준비하세요.",color:"red"}
scoreboard players set #test_active game_data 0
scoreboard players set #test_busy game_data 0
schedule clear botc_test:ready
schedule clear botc_test:day_ready
schedule clear botc_test:vote_start
schedule clear botc_test:vote_done
schedule clear ct:loop/vote/loop
schedule clear ct:loop/vote/end_voting
schedule clear ct:loop/vote/cd/2
schedule clear ct:loop/vote/cd/1
schedule clear ct:loop/vote/cd/0
function ct:admin/reset_game
execute if entity @a[name=Alex,tag=botc_test] run player Alex kill
execute if entity @a[name=Steve,tag=botc_test] run player Steve kill
execute if entity @a[name=Ari,tag=botc_test] run player Ari kill
execute if entity @a[name=efe,tag=botc_test] run player efe kill
execute if entity @a[name=Kai,tag=botc_test] run player Kai kill
execute if entity @a[name=Makena,tag=botc_test] run player Makena kill
execute if entity @a[name=Emma,tag=botc_test] run player Emma kill
execute if entity @a[name=Sunny,tag=botc_test] run player Sunny kill
tag @s remove botc_test_controller
tellraw @s {text:"테스트 종료. 가상 참가자를 접속 종료하고 게임을 초기화했습니다.",color:"yellow"}
