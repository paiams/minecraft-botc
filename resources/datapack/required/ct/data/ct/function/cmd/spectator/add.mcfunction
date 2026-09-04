execute if entity @s[tag=!storyteller] run return run function ct:error/not_storyteller
execute if score phase game_data matches 1.. run return run function ct:error/game_active

$execute as $(target) if entity @s[tag=!spectator] run tellraw @a[tag=storyteller] {"translate":"clocktower.notice.spectator.added","with":[{"text":"$(target)"}]}
$execute as $(target) if entity @s[tag=!spectator] run tellraw @s {"translate":"clocktower.notice.spectator.added_self"}

$execute as $(target) if entity @s[tag=!spectator] run team join 00_spectator @s
$execute as $(target) if entity @s[tag=!spectator] run tag @s remove storyteller
$execute as $(target) if entity @s[tag=!spectator] run tag @s add spectator
$execute as $(target) if entity @s[tag=spectator] run function ct:admin/give_script
