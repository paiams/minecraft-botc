execute unless entity @s[tag=storyteller] run return 0
execute unless score phase game_data matches 0 run return 0
$scoreboard players set #bag_count game_data $(count)
execute unless score #bag_count game_data matches 5..15 run return 0
scoreboard players operation player_count game_data = #bag_count game_data
execute store result storage ct:bag count int 1 run scoreboard players get #bag_count game_data
function ct:admin/setup/set_from_menu
