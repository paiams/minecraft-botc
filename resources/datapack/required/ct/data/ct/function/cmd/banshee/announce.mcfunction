execute if entity @s[tag=!storyteller] run return run function ct:error/not_storyteller
execute if score phase game_data matches 0 run return run function ct:error/game_not_active

execute as @a run fmvariable set announcement false banshee
execute as @a at @s run playsound ct:clocktower.night.banshee voice @s
tellraw @a [{"text":"! ","color":"blue","bold":true},{"translate":"clocktower.prefix.the","color":"gray","bold":false},{"translate":"clocktower.role.banshee.name","color":"blue","bold":false},{"translate":"clocktower.notice.banshee.awoken_suffix","color":"gray","bold":false}]

schedule function ct:admin/announce/reset 4s
