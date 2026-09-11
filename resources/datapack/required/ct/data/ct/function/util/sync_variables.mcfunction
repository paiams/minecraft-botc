execute as @a[tag=!storyteller] run fmvariable set storyteller false false
execute as @a[tag=storyteller] run fmvariable set storyteller false true

# Rebuild client visibility state from the authoritative server phase.
execute if score phase game_data matches 0 as @a run fmvariable set game_active false false
execute if score phase game_data matches 1.. as @a run fmvariable set game_active false true
execute if score phase game_data matches 1.. as @a run function ct:start_game/roles/set_grim_variables with storage ct:players players

execute as @a run function ct:util/update_shrouds
scoreboard players set @a[tag=rejoining] vc 0
tag @a[tag=rejoining] remove rejoining

function ct:util/scores_to_variables
schedule function ct:util/scores_to_variables 1s
