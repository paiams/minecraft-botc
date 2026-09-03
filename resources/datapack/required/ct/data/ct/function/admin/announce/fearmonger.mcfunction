execute if entity @s[tag=!storyteller] run return run function ct:error/not_storyteller
execute if score phase game_data matches 0 run return run function ct:error/game_not_active

execute as @a run fmvariable set announcement false fearmonger
execute as @a at @s run playsound ct:clocktower.night.fearmonger_victim voice @s
tellraw @a [{"text":"! ","color":"red","bold":true},{"translate":"clocktower.prefix.the","color":"gray","bold":false},{"translate":"clocktower.role.fearmonger.name","color":"red","bold":false},{"translate":"clocktower.notice.fearmonger.target_selected_suffix","color":"gray","bold":false}]
schedule function ct:admin/announce/reset 4s
