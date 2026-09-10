execute unless entity @a[team=01_red] run team join 01_red @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=02_orange] run team join 02_orange @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=03_yellow] run team join 03_yellow @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=04_lime] run team join 04_lime @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=05_green] run team join 05_green @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=06_mint] run team join 06_mint @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=07_cyan] run team join 07_cyan @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=08_blue] run team join 08_blue @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=09_navy] run team join 09_navy @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=10_purple] run team join 10_purple @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=11_magenta] run team join 11_magenta @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=12_lavender] run team join 12_lavender @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=13_white] run team join 13_white @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=14_gray] run team join 14_gray @r[team=,tag=!storyteller,tag=!spectator]
execute unless entity @a[team=15_black] run team join 15_black @r[team=,tag=!storyteller,tag=!spectator]

function ct:util/color_names

data modify block 121 72 68 front_text.messages[1] set value {"selector":"@a[team=01_red]"}
data modify block 120 72 65 front_text.messages[1] set value {"selector":"@a[team=02_orange]"}
data modify block 120 72 62 front_text.messages[1] set value {"selector":"@a[team=03_yellow]"}
data modify block 121 72 59 front_text.messages[1] set value {"selector":"@a[team=04_lime]"}
data modify block 122 72 58 front_text.messages[1] set value {"selector":"@a[team=05_green]"}
data modify block 125 72 57 front_text.messages[1] set value {"selector":"@a[team=06_mint]"}
data modify block 128 72 57 front_text.messages[1] set value {"selector":"@a[team=07_cyan]"}
data modify block 131 72 58 front_text.messages[1] set value {"selector":"@a[team=08_blue]"}
data modify block 132 72 59 front_text.messages[1] set value {"selector":"@a[team=09_navy]"}
data modify block 133 72 62 front_text.messages[1] set value {"selector":"@a[team=10_purple]"}
data modify block 133 72 65 front_text.messages[1] set value {"selector":"@a[team=11_magenta]"}
data modify block 132 72 68 front_text.messages[1] set value {"selector":"@a[team=12_lavender]"}
data modify block 131 72 69 front_text.messages[1] set value {"selector":"@a[team=13_white]"}
data modify block 128 72 70 front_text.messages[1] set value {"selector":"@a[team=14_gray]"}
data modify block 125 72 70 front_text.messages[1] set value {"selector":"@a[team=15_black]"}

data remove storage ct:players players

execute if data block 121 72 68 front_text.messages[1].text run data modify storage ct:players players.p1 set from block 121 72 68 front_text.messages[1].hover_event.name
execute if data block 120 72 65 front_text.messages[1].text run data modify storage ct:players players.p2 set from block 120 72 65 front_text.messages[1].hover_event.name
execute if data block 120 72 62 front_text.messages[1].text run data modify storage ct:players players.p3 set from block 120 72 62 front_text.messages[1].hover_event.name
execute if data block 121 72 59 front_text.messages[1].text run data modify storage ct:players players.p4 set from block 121 72 59 front_text.messages[1].hover_event.name
execute if data block 122 72 58 front_text.messages[1].text run data modify storage ct:players players.p5 set from block 122 72 58 front_text.messages[1].hover_event.name
execute if data block 125 72 57 front_text.messages[1].text run data modify storage ct:players players.p6 set from block 125 72 57 front_text.messages[1].hover_event.name
execute if data block 128 72 57 front_text.messages[1].text run data modify storage ct:players players.p7 set from block 128 72 57 front_text.messages[1].hover_event.name
execute if data block 131 72 58 front_text.messages[1].text run data modify storage ct:players players.p8 set from block 131 72 58 front_text.messages[1].hover_event.name
execute if data block 132 72 59 front_text.messages[1].text run data modify storage ct:players players.p9 set from block 132 72 59 front_text.messages[1].hover_event.name
execute if data block 133 72 62 front_text.messages[1].text run data modify storage ct:players players.p10 set from block 133 72 62 front_text.messages[1].hover_event.name
execute if data block 133 72 65 front_text.messages[1].text run data modify storage ct:players players.p11 set from block 133 72 65 front_text.messages[1].hover_event.name
execute if data block 132 72 68 front_text.messages[1].text run data modify storage ct:players players.p12 set from block 132 72 68 front_text.messages[1].hover_event.name
execute if data block 131 72 69 front_text.messages[1].text run data modify storage ct:players players.p13 set from block 131 72 69 front_text.messages[1].hover_event.name
execute if data block 128 72 70 front_text.messages[1].text run data modify storage ct:players players.p14 set from block 128 72 70 front_text.messages[1].hover_event.name
execute if data block 125 72 70 front_text.messages[1].text run data modify storage ct:players players.p15 set from block 125 72 70 front_text.messages[1].hover_event.name

execute unless data block 121 72 68 front_text.messages[1].text run data modify storage ct:players players.p1 set value "Nobody!"
execute unless data block 120 72 65 front_text.messages[1].text run data modify storage ct:players players.p2 set value "Nobody!"
execute unless data block 120 72 62 front_text.messages[1].text run data modify storage ct:players players.p3 set value "Nobody!"
execute unless data block 121 72 59 front_text.messages[1].text run data modify storage ct:players players.p4 set value "Nobody!"
execute unless data block 122 72 58 front_text.messages[1].text run data modify storage ct:players players.p5 set value "Nobody!"
execute unless data block 125 72 57 front_text.messages[1].text run data modify storage ct:players players.p6 set value "Nobody!"
execute unless data block 128 72 57 front_text.messages[1].text run data modify storage ct:players players.p7 set value "Nobody!"
execute unless data block 131 72 58 front_text.messages[1].text run data modify storage ct:players players.p8 set value "Nobody!"
execute unless data block 132 72 59 front_text.messages[1].text run data modify storage ct:players players.p9 set value "Nobody!"
execute unless data block 133 72 62 front_text.messages[1].text run data modify storage ct:players players.p10 set value "Nobody!"
execute unless data block 133 72 65 front_text.messages[1].text run data modify storage ct:players players.p11 set value "Nobody!"
execute unless data block 132 72 68 front_text.messages[1].text run data modify storage ct:players players.p12 set value "Nobody!"
execute unless data block 131 72 69 front_text.messages[1].text run data modify storage ct:players players.p13 set value "Nobody!"
execute unless data block 128 72 70 front_text.messages[1].text run data modify storage ct:players players.p14 set value "Nobody!"
execute unless data block 125 72 70 front_text.messages[1].text run data modify storage ct:players players.p15 set value "Nobody!"

data modify entity @e[tag=house_head,limit=1,scores={house_id=1}] item.components.minecraft:profile.name set from storage ct:players players.p1
data modify entity @e[tag=house_head,limit=1,scores={house_id=2}] item.components.minecraft:profile.name set from storage ct:players players.p2
data modify entity @e[tag=house_head,limit=1,scores={house_id=3}] item.components.minecraft:profile.name set from storage ct:players players.p3
data modify entity @e[tag=house_head,limit=1,scores={house_id=4}] item.components.minecraft:profile.name set from storage ct:players players.p4
data modify entity @e[tag=house_head,limit=1,scores={house_id=5}] item.components.minecraft:profile.name set from storage ct:players players.p5
data modify entity @e[tag=house_head,limit=1,scores={house_id=6}] item.components.minecraft:profile.name set from storage ct:players players.p6
data modify entity @e[tag=house_head,limit=1,scores={house_id=7}] item.components.minecraft:profile.name set from storage ct:players players.p7
data modify entity @e[tag=house_head,limit=1,scores={house_id=8}] item.components.minecraft:profile.name set from storage ct:players players.p8
data modify entity @e[tag=house_head,limit=1,scores={house_id=9}] item.components.minecraft:profile.name set from storage ct:players players.p9
data modify entity @e[tag=house_head,limit=1,scores={house_id=10}] item.components.minecraft:profile.name set from storage ct:players players.p10
data modify entity @e[tag=house_head,limit=1,scores={house_id=11}] item.components.minecraft:profile.name set from storage ct:players players.p11
data modify entity @e[tag=house_head,limit=1,scores={house_id=12}] item.components.minecraft:profile.name set from storage ct:players players.p12
data modify entity @e[tag=house_head,limit=1,scores={house_id=13}] item.components.minecraft:profile.name set from storage ct:players players.p13
data modify entity @e[tag=house_head,limit=1,scores={house_id=14}] item.components.minecraft:profile.name set from storage ct:players players.p14
data modify entity @e[tag=house_head,limit=1,scores={house_id=15}] item.components.minecraft:profile.name set from storage ct:players players.p15

execute as @e[type=minecraft:text_display,tag=home_label] run data modify entity @s view_range set value 0
execute as @e[type=minecraft:text_display,tag=home_label] if score @s house_id <= player_count game_data run data modify entity @s view_range set value 1

function ct:util/color_prefixes

scoreboard players set @a[team=01_red] id 1
scoreboard players set @a[team=02_orange] id 2
scoreboard players set @a[team=03_yellow] id 3
scoreboard players set @a[team=04_lime] id 4
scoreboard players set @a[team=05_green] id 5
scoreboard players set @a[team=06_mint] id 6
scoreboard players set @a[team=07_cyan] id 7
scoreboard players set @a[team=08_blue] id 8
scoreboard players set @a[team=09_navy] id 9
scoreboard players set @a[team=10_purple] id 10
scoreboard players set @a[team=11_magenta] id 11
scoreboard players set @a[team=12_lavender] id 12
scoreboard players set @a[team=13_white] id 13
scoreboard players set @a[team=14_gray] id 14
scoreboard players set @a[team=15_black] id 15

execute as @e[type=minecraft:item_display,tag=house_head] run data modify entity @s view_range set value 0
execute as @e[type=minecraft:item_display,tag=house_head] if score @s house_id <= player_count game_data run data modify entity @s view_range set value 1
