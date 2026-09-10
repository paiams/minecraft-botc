data modify storage ct:grimoire edit set value {}
execute store result storage ct:grimoire edit.seat int 1 run scoreboard players get @s id
$data modify storage ct:grimoire edit.character set value "$(character)"
function ct:cmd/grimoire_role_store with storage ct:grimoire edit
execute if score phase game_data matches 0 run scoreboard players operation @s role = #role game_data
execute if score phase game_data matches 0 run tag @s add has_role
