execute as @a[scores={use_carrot=1..}] run function ct:loop/player/use_item

execute as @a unless score @s join_game matches 0 run function ct:loop/player/join_game

execute if score cd rps matches 1.. run function ct:rps/cd
execute if score bd_cd game_data matches -21.. run function ct:loop/boomdandy/cd

execute if score phase game_data matches 2 run function ct:loop/day
execute if score phase game_data matches 3 run function ct:loop/dusk
execute if score phase game_data matches 1..3 if entity @a[tag=nominee] as @a run function ct:loop/player/voting
execute if score phase game_data matches 1..3 if entity @a[tag=nominee] run function ct:loop/vote/update_counter
execute if score phase game_data matches 1..3 as @a[tag=marked_for_execution] at @s run particle minecraft:sculk_soul ~ ~1 ~ 0.3 0.6 0.3 0 1 force @a
execute if score phase game_data matches 4 run function ct:loop/night

execute if entity @a[tag=requesting_chat] run title @a[tag=storyteller] actionbar [{"text":"! ","color":"yellow","bold":true},{"translate":"clocktower.notice.chat_request_storyteller","color":"white","bold":false,"with":[{"selector":"@a[tag=requesting_chat]"}]}]
execute as @a[tag=requesting_chat] run title @s actionbar [{"text":"! ","color":"yellow","bold":true},{"translate":"clocktower.notice.chat_request_you","color":"white","bold":false}]

scoreboard players set player_count game_data 0
execute as @a[tag=!storyteller,tag=!spectator] run scoreboard players add player_count game_data 1
execute unless score player_count game_data = stored_player_count game_data run function ct:util/update_game_data
