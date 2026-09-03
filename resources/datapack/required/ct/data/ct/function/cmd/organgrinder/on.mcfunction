execute if entity @s[tag=!storyteller] run return run function ct:error/not_storyteller
execute if score phase game_data matches 0 run return run function ct:error/game_not_active

tellraw @s [{"text":"! ","color":"yellow","bold":true},{"translate":"clocktower.role.organgrinder.name","color":"gray","bold":false},{"translate":"clocktower.notice.organgrinder.enabled_suffix","color":"green","bold":true}]
scoreboard players set organ_grinder settings 1
execute as @a[tag=storyteller] run fmvariable set organgrinder false on
