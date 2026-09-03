execute if entity @s[tag=!storyteller] run return run function ct:error/not_storyteller
execute if score phase game_data matches 1.. run return run function ct:error/game_active

$execute if entity @s[tag=!spectator] run tellraw @a[tag=storyteller] {"translate":"clocktower.notice.spectator.added","with":[{"text":"$(target)"}]}
execute if entity @s[tag=!spectator] run tellraw @s {"translate":"clocktower.notice.spectator.added_self"}

execute if entity @s[tag=!spectator] run team join 00_spectator @s
tag @s remove storyteller
tag @s add spectator
function ct:admin/give_script
