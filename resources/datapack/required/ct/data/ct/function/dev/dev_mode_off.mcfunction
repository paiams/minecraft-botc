scoreboard players set dev_mode game_data 0
fmvariable set dev false false
gamerule send_command_feedback false
gamerule reduced_debug_info true
gamerule spectators_generate_chunks false

tellraw @s [{"translate":"clocktower.prefix.notification","color":"yellow"},{"translate":"clocktower.notice.dev_mode.disabled_suffix","color":"gray"}]
