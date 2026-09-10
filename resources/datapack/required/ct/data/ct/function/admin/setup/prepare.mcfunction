execute unless score phase game_data matches 0 run return 0
scoreboard players set #prepared game_data 1
execute as @a if score player_count game_data matches 5 run function ct:start_game/roles/pcount {player:5,town:3,outsider:0,minion:1,demon:1}
execute as @a if score player_count game_data matches 6 run function ct:start_game/roles/pcount {player:6,town:3,outsider:1,minion:1,demon:1}
execute as @a if score player_count game_data matches 7 run function ct:start_game/roles/pcount {player:7,town:5,outsider:0,minion:1,demon:1}
execute as @a if score player_count game_data matches 8 run function ct:start_game/roles/pcount {player:8,town:5,outsider:1,minion:1,demon:1}
execute as @a if score player_count game_data matches 9 run function ct:start_game/roles/pcount {player:9,town:5,outsider:2,minion:1,demon:1}
execute as @a if score player_count game_data matches 10 run function ct:start_game/roles/pcount {player:10,town:7,outsider:0,minion:2,demon:1}
execute as @a if score player_count game_data matches 11 run function ct:start_game/roles/pcount {player:11,town:7,outsider:1,minion:2,demon:1}
execute as @a if score player_count game_data matches 12 run function ct:start_game/roles/pcount {player:12,town:7,outsider:2,minion:2,demon:1}
execute as @a if score player_count game_data matches 13 run function ct:start_game/roles/pcount {player:13,town:9,outsider:0,minion:3,demon:1}
execute as @a if score player_count game_data matches 14 run function ct:start_game/roles/pcount {player:14,town:9,outsider:1,minion:3,demon:1}
execute as @a if score player_count game_data matches 15 run function ct:start_game/roles/pcount {player:15,town:9,outsider:2,minion:3,demon:1}

execute as @a[tag=!storyteller,tag=!spectator] if score @s id > player_count game_data run team leave @s
function ct:start_game/refresh_seats
data remove storage ct:grimoire roles
scoreboard players set @a[tag=!storyteller,tag=!spectator] role 0
tag @a[tag=!storyteller,tag=!spectator] remove has_role
execute as @a[tag=!storyteller,tag=!spectator] if score @s id <= player_count game_data run function ct:start_game/give_role
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
function ct:util/sync_variables
