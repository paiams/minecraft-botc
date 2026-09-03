execute if score organ_grinder settings matches 1 if entity @s[tag=dead,tag=voted_today] run return fail

scoreboard players set @s use_carrot 0
tag @s remove voting_no
tag @s remove voting_banshee
tag @s[tag=!dead] add voting_yes
tag @s[tag=dead] add voting_ghost
tellraw @s[tag=!dead,tag=!expended_ghost] {"translate":"clocktower.notice.voting.changed","with":[{"translate":"clocktower.vote.yes","color":"green"},{"selector":"@a[tag=nominee]"}]}
tellraw @s[tag=dead,tag=!expended_ghost] {"translate":"clocktower.notice.voting.changed","with":[{"translate":"clocktower.vote.yes","color":"aqua"},{"selector":"@a[tag=nominee]"}]}
item replace entity @s[tag=!dead,tag=!expended_ghost] weapon.offhand with minecraft:carrot_on_a_stick[minecraft:custom_model_data={"strings":["voting_yes"]},custom_name=[{translate:"clocktower.item.voting_prefix",color:"white",italic:false},{translate:"clocktower.vote.yes",color:"green",italic:false},{translate:"clocktower.item.right_click",color:"gray",italic:false}]]
item replace entity @s[tag=dead,tag=!expended_ghost] weapon.offhand with minecraft:carrot_on_a_stick[minecraft:custom_model_data={"strings":["voting_ghost"]},custom_name=[{translate:"clocktower.item.voting_prefix",color:"white",italic:false},{translate:"clocktower.vote.yes",color:"aqua",italic:false},{translate:"clocktower.item.right_click",color:"gray",italic:false}]]

tag @s add toggling_vote
execute as @e[type=minecraft:item_display,tag=vote_marker] at @s if score @s id = @a[limit=1,tag=toggling_vote,tag=!dead] id run data modify entity @s item.components."minecraft:custom_model_data".strings[0] set value "voting_yes"
execute as @e[type=minecraft:item_display,tag=vote_marker] at @s if score @s id = @a[limit=1,tag=toggling_vote,tag=dead] id run data modify entity @s item.components."minecraft:custom_model_data".strings[0] set value "voting_ghost"
tag @s remove toggling_vote
