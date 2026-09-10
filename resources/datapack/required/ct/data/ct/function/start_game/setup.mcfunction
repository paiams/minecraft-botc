execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 0 run return 0
scoreboard players set #online game_data 0
execute as @a[tag=!storyteller,tag=!spectator] run scoreboard players add #online game_data 1
execute unless score #prepared game_data matches 1 run scoreboard players operation player_count game_data = #online game_data
execute unless score #online game_data = player_count game_data run return run tellraw @s {text:"설정 가방의 인원과 참가 인원이 다릅니다. 가방을 다시 적용해 주세요.",color:"red"}
execute if score player_count game_data matches ..4 run return run function ct:error/not_enough_players
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
execute if score player_count game_data matches 16.. run return run function ct:error/too_many_players

execute store result score active_game game_id run random value 1..2147483647
scoreboard players operation @a[tag=!storyteller] game_id = active_game game_id
scoreboard players set @a[tag=!storyteller,tag=!has_role] role 0
scoreboard players set @a[tag=!storyteller,tag=!spectator] reveal_cd 140
scoreboard players set @a[tag=!storyteller,tag=!spectator] vote_value 1
execute as @a run fmvariable set role false none
execute as @a run fmvariable set game_active false true
title @a times 1s 2s 1s

gamemode spectator @a[tag=spectator]

function ct:start_game/refresh_seats

function ct:phase/night
clear @a[tag=!storyteller] minecraft:carrot_on_a_stick
item replace entity @a[tag=!storyteller,tag=!spectator] hotbar.0 with minecraft:writable_book[minecraft:custom_model_data={strings:["script"]},custom_name=[{translate:"clocktower.item.notebook.name",color:"yellow",italic:false},{translate:"clocktower.item.right_click",color:"gray",italic:false}]]
execute as @a run function ct:admin/give_script

execute as @a run function ct:start_game/roles/set_grim_variables with storage ct:players players
execute as @a[tag=!storyteller,tag=!spectator] run loot give @s loot ct:compass

execute as @a[tag=!has_role,tag=!storyteller,tag=!spectator,sort=random,limit=1] run function ct:start_game/give_role
execute as @a[tag=!has_role,tag=!storyteller,tag=!spectator,sort=random,limit=1] run function ct:start_game/random_roles
scoreboard players set @a[tag=!storyteller,tag=!spectator] vote_value 1
schedule function ct:start_game/roles/reveal_to_st 1t
schedule function ct:start_game/apply_labels 2t
schedule function ct:admin/variables/score 3t
schedule function ct:util/sync_variables 4t
