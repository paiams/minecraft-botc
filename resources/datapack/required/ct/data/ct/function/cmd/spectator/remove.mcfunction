execute if entity @s[tag=!storyteller] run return run function ct:error/not_storyteller
execute unless score phase game_data matches 0 run return run function ct:error/game_active

$execute if entity @s[tag=spectator] run tellraw @a[tag=storyteller] {"translate":"clocktower.notice.spectator.removed","with":[{"text":"$(target)"}]}
execute if entity @s[tag=spectator] run tellraw @s {"translate":"clocktower.notice.spectator.removed_self"}

execute if entity @s[tag=spectator] run team leave @s
tag @s remove spectator
