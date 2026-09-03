execute as @a run fmvariable set phase false 3
scoreboard players set phase game_data 3
time set 12200
execute as @e[type=minecraft:item_display,tag=vc] run data modify entity @s view_range set value 0
execute as @e[type=minecraft:item_display,tag=exclamation_red] run data modify entity @s view_range set value 1

gamerule advance_time false

scoreboard players set current_majority vote 0
scoreboard players set already_incremented vote 0

execute as @a at @s run playsound ct:clocktower.bell voice @s

tellraw @a [{"text":"⌚ ","color":"red"},{"translate":"clocktower.notice.phase.dusk","color":"gray"}]
tellraw @a {"translate":"clocktower.notice.phase.dusk_nominations","color":"gray"}
