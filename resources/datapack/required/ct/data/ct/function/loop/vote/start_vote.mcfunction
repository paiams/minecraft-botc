scoreboard players set @s use_carrot 0
function ct:loop/vote/required_votes
scoreboard players set total vote 0
execute as @e[type=minecraft:item_display,tag=arm] run data modify entity @s view_range set value 1

scoreboard players operation current vote = @a[tag=nominee] id
scoreboard players add current vote 1
execute if score current vote > player_count game_data run scoreboard players set current vote 1
scoreboard players operation start vote = current vote
execute as @a if score @s id = current vote run tag @s add vote_start

function ct:util/color_names
execute if score organ_grinder settings matches 0 if score current_majority vote matches 0 run tellraw @a {"translate":"clocktower.notice.vote_started","with":[{"selector":"@a[tag=nominee]"},{"selector":"@a[tag=vote_start]"},{"score":{"name":"majority","objective":"math"},"bold":true,"color":"white"}]}
execute if score organ_grinder settings matches 0 unless score current_majority vote matches 0 run tellraw @a {"translate":"clocktower.notice.vote_started","with":[{"selector":"@a[tag=nominee]"},{"selector":"@a[tag=vote_start]"},{"score":{"name":"current_majority","objective":"vote"},"bold":true,"color":"white"}]}
execute if score organ_grinder settings matches 1 run tellraw @a {"translate":"clocktower.notice.vote_started_blind","with":[{"selector":"@a[tag=nominee]"},{"selector":"@a[tag=vote_start]"}]}
function ct:util/color_prefixes

tag @a remove vote_start

clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["start_vote"]}]
function ct:loop/vote/cd/3
function #ct:broadcast/vote_started
