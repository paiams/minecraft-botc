execute unless score #test_active game_data matches 1 run return 0
function ct:phase/dawn
function ct:phase/day
effect clear @a[tag=botc_test] minecraft:blindness
execute as @a[tag=botc_test_controller] at @s run function ct:cmd/tpseats
tp @a[tag=botc_test_controller] 126 77 66 180 35
scoreboard players set #test_busy game_data 0
tellraw @a[tag=botc_test_controller] {text:"첫날 낮 준비 완료. 자동 투표를 선택하세요.",color:"green"}
execute as @a[tag=botc_test_controller] run function botc_test:menu
