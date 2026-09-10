execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 0 run return 0
$scoreboard players set #seat game_data $(id)
execute unless score #seat game_data matches 1..15 run return 0
execute if score #seat game_data > player_count game_data run return 0
$scoreboard players set #next game_data $(target)
execute unless score #next game_data matches 1..15 run return 0
execute if score #next game_data > player_count game_data run return 0
execute if score #next game_data = #seat game_data run return 0
$execute unless entity @a[tag=!storyteller,tag=!spectator,scores={id=$(id)}] run return 0
$execute unless entity @a[tag=!storyteller,tag=!spectator,scores={id=$(target)}] run return 0
tag @a remove seat_swap_source
execute as @a[tag=!storyteller,tag=!spectator] if score @s id = #seat game_data run tag @s add seat_swap_source
execute as @a[tag=!storyteller,tag=!spectator,tag=!seat_swap_source] if score @s id = #next game_data run scoreboard players operation @s id = #seat game_data
scoreboard players operation @a[tag=seat_swap_source] id = #next game_data
tag @a remove seat_swap_source
team join 01_red @a[tag=!storyteller,tag=!spectator,scores={id=1}]
team join 02_orange @a[tag=!storyteller,tag=!spectator,scores={id=2}]
team join 03_yellow @a[tag=!storyteller,tag=!spectator,scores={id=3}]
team join 04_lime @a[tag=!storyteller,tag=!spectator,scores={id=4}]
team join 05_green @a[tag=!storyteller,tag=!spectator,scores={id=5}]
team join 06_mint @a[tag=!storyteller,tag=!spectator,scores={id=6}]
team join 07_cyan @a[tag=!storyteller,tag=!spectator,scores={id=7}]
team join 08_blue @a[tag=!storyteller,tag=!spectator,scores={id=8}]
team join 09_navy @a[tag=!storyteller,tag=!spectator,scores={id=9}]
team join 10_purple @a[tag=!storyteller,tag=!spectator,scores={id=10}]
team join 11_magenta @a[tag=!storyteller,tag=!spectator,scores={id=11}]
team join 12_lavender @a[tag=!storyteller,tag=!spectator,scores={id=12}]
team join 13_white @a[tag=!storyteller,tag=!spectator,scores={id=13}]
team join 14_gray @a[tag=!storyteller,tag=!spectator,scores={id=14}]
team join 15_black @a[tag=!storyteller,tag=!spectator,scores={id=15}]
data remove storage ct:grimoire roles
function ct:start_game/refresh_seats
execute as @a run function ct:start_game/roles/set_grim_variables with storage ct:players players
execute as @a[tag=storyteller] run fmvariable set p1_role false none
execute as @a[scores={id=1}] run function ct:start_game/roles/set_grim_roles {id:1}
execute as @a[tag=storyteller] run fmvariable set p2_role false none
execute as @a[scores={id=2}] run function ct:start_game/roles/set_grim_roles {id:2}
execute as @a[tag=storyteller] run fmvariable set p3_role false none
execute as @a[scores={id=3}] run function ct:start_game/roles/set_grim_roles {id:3}
execute as @a[tag=storyteller] run fmvariable set p4_role false none
execute as @a[scores={id=4}] run function ct:start_game/roles/set_grim_roles {id:4}
execute as @a[tag=storyteller] run fmvariable set p5_role false none
execute as @a[scores={id=5}] run function ct:start_game/roles/set_grim_roles {id:5}
execute as @a[tag=storyteller] run fmvariable set p6_role false none
execute as @a[scores={id=6}] run function ct:start_game/roles/set_grim_roles {id:6}
execute as @a[tag=storyteller] run fmvariable set p7_role false none
execute as @a[scores={id=7}] run function ct:start_game/roles/set_grim_roles {id:7}
execute as @a[tag=storyteller] run fmvariable set p8_role false none
execute as @a[scores={id=8}] run function ct:start_game/roles/set_grim_roles {id:8}
execute as @a[tag=storyteller] run fmvariable set p9_role false none
execute as @a[scores={id=9}] run function ct:start_game/roles/set_grim_roles {id:9}
execute as @a[tag=storyteller] run fmvariable set p10_role false none
execute as @a[scores={id=10}] run function ct:start_game/roles/set_grim_roles {id:10}
execute as @a[tag=storyteller] run fmvariable set p11_role false none
execute as @a[scores={id=11}] run function ct:start_game/roles/set_grim_roles {id:11}
execute as @a[tag=storyteller] run fmvariable set p12_role false none
execute as @a[scores={id=12}] run function ct:start_game/roles/set_grim_roles {id:12}
execute as @a[tag=storyteller] run fmvariable set p13_role false none
execute as @a[scores={id=13}] run function ct:start_game/roles/set_grim_roles {id:13}
execute as @a[tag=storyteller] run fmvariable set p14_role false none
execute as @a[scores={id=14}] run function ct:start_game/roles/set_grim_roles {id:14}
execute as @a[tag=storyteller] run fmvariable set p15_role false none
execute as @a[scores={id=15}] run function ct:start_game/roles/set_grim_roles {id:15}
fmvariable set swap_selecting false false
fmvariable set swap_source false 0
fmvariable set editing_player false 0
fmlayout ct-grimoire_actions false
