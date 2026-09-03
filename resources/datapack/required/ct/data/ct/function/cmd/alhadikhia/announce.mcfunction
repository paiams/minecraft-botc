execute if entity @s[tag=!storyteller] run return run function ct:error/not_storyteller
execute if score phase game_data matches 0 run return run function ct:error/game_not_active

$execute as @a run fmvariable set announced_player false $(p)
execute as @a run fmvariable set announcement false alhad
execute as @a at @s run playsound ct:clocktower.night.alhad_announcement voice @s
tellraw @a [{"text":"! ","color":"red","bold":true},{"translate":"clocktower.prefix.the","color":"gray","bold":false},{"translate":"clocktower.role.alhadikhia.name","color":"red","bold":false},{"translate":"clocktower.notice.alhadikhia.target_selected_suffix","color":"gray","bold":false}]
schedule function ct:cmd/alhadikhia/name 2s
