execute if entity @s[tag=!storyteller] run return run function ct:error/not_storyteller
execute unless score phase game_data matches 0 run return run function ct:error/game_active

$execute as $(target) if entity @s[tag=spectator] run tellraw @a[tag=storyteller] {"translate":"clocktower.notice.spectator.removed","with":[{"text":"$(target)"}]}
$execute as $(target) if entity @s[tag=spectator] run tellraw @s {"translate":"clocktower.notice.spectator.removed_self"}

$execute as $(target) if entity @s[tag=spectator] run team leave @s
$execute as $(target) if entity @s[tag=spectator] run tag @s remove spectator
