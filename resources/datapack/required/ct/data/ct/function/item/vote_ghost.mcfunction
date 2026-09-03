scoreboard players set @s use_carrot 0
tag @s remove voting_yes
tag @s remove voting_ghost
tag @s[tag=!active_banshee] add voting_no
tag @s[tag=active_banshee] add voting_banshee
tellraw @s[tag=!active_banshee] {"translate":"clocktower.notice.voting.changed","with":[{"translate":"clocktower.vote.no","color":"red"},{"selector":"@a[tag=nominee]"}]}
tellraw @s[tag=active_banshee] {"translate":"clocktower.notice.voting.changed","with":[{"translate":"clocktower.vote.yes_x2","color":"aqua"},{"selector":"@a[tag=nominee]"}]}
item replace entity @s[tag=!active_banshee] weapon.offhand with minecraft:carrot_on_a_stick[minecraft:custom_model_data={"strings":["voting_no"]},custom_name=[{translate:"clocktower.item.voting_prefix",color:"white",italic:false},{translate:"clocktower.vote.no",color:"red",italic:false},{translate:"clocktower.item.right_click",color:"gray",italic:false}]]
item replace entity @s[tag=active_banshee] weapon.offhand with minecraft:carrot_on_a_stick[minecraft:custom_model_data={"strings":["voting_banshee"]},custom_name=[{translate:"clocktower.item.voting_prefix",color:"white",italic:false},{translate:"clocktower.vote.yes_x2",color:"aqua",italic:false},{translate:"clocktower.item.right_click",color:"gray",italic:false}]]

tag @s add toggling_vote
execute as @e[type=minecraft:item_display,tag=vote_marker] at @s if score @s id = @a[limit=1,tag=toggling_vote,tag=!active_banshee] id run data modify entity @s item.components."minecraft:custom_model_data".strings[0] set value "voting_no"
execute as @e[type=minecraft:item_display,tag=vote_marker] at @s if score @s id = @a[limit=1,tag=toggling_vote,tag=active_banshee] id run data modify entity @s item.components."minecraft:custom_model_data".strings[0] set value "voting_banshee"
tag @s remove toggling_vote
