# Carpet fake-player logins are asynchronous.
execute unless score #test_active game_data matches 1 run return 0
scoreboard players set #test_busy game_data 0
scoreboard players set #test_count game_data 0
execute if entity @a[name=Alex,tag=!storyteller] run scoreboard players add #test_count game_data 1
execute if entity @a[name=Steve,tag=!storyteller] run scoreboard players add #test_count game_data 1
execute if entity @a[name=Ari,tag=!storyteller] run scoreboard players add #test_count game_data 1
execute if entity @a[name=efe,tag=!storyteller] run scoreboard players add #test_count game_data 1
execute if entity @a[name=Kai,tag=!storyteller] run scoreboard players add #test_count game_data 1
execute if entity @a[name=Makena,tag=!storyteller] run scoreboard players add #test_count game_data 1
execute if entity @a[name=Emma,tag=!storyteller] run scoreboard players add #test_count game_data 1
execute if entity @a[name=Sunny,tag=!storyteller] run scoreboard players add #test_count game_data 1
execute unless score #test_count game_data matches 8 run return run tellraw @a[tag=botc_test_controller] {text:"8인 접속이 완료되지 않았습니다. /botc_test setup 을 다시 실행하세요.",color:"red"}
tag @a[name=Alex,tag=!storyteller] add botc_test
tag @a[name=Steve,tag=!storyteller] add botc_test
tag @a[name=Ari,tag=!storyteller] add botc_test
tag @a[name=efe,tag=!storyteller] add botc_test
tag @a[name=Kai,tag=!storyteller] add botc_test
tag @a[name=Makena,tag=!storyteller] add botc_test
tag @a[name=Emma,tag=!storyteller] add botc_test
tag @a[name=Sunny,tag=!storyteller] add botc_test
scoreboard players set player_count game_data 8
data modify storage ct:roles roles set value [{id:12,name:"chef"},{id:18,name:"empath"},{id:33,name:"investigator"},{id:37,name:"librarian"},{id:69,name:"washerwoman"},{id:201,name:"butler"},{id:316,name:"poisoner"},{id:402,name:"imp"}]
function ct:admin/setup/prepare
execute as @a[tag=botc_test_controller] run function ct:admin/give_script
tellraw @a[tag=botc_test_controller] {text:"8인 준비 완료. 첫날 밤 전이므로 마도서의 역할·좌석을 바꿔 볼 수 있습니다.",color:"green"}
execute as @a[tag=botc_test_controller] run function botc_test:menu
