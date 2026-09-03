scoreboard players set @s use_carrot 0
tag @s remove voting_yes
tag @s remove voting_banshee
tag @s add voting_no
tellraw @s {"translate":"clocktower.notice.voting.changed","with":[{"translate":"clocktower.vote.no","color":"red"},{"selector":"@a[tag=nominee]"}]}
item replace entity @s weapon.offhand with minecraft:carrot_on_a_stick[minecraft:custom_model_data={"strings":["voting_no"]},custom_name=[{translate:"clocktower.item.voting_prefix",color:"white",italic:false},{translate:"clocktower.vote.no",color:"red",italic:false},{translate:"clocktower.item.right_click",color:"gray",italic:false}]]

tag @s add toggling_vote
execute as @e[type=minecraft:item_display,tag=vote_marker] at @s if score @s id = @a[limit=1,tag=toggling_vote] id run data modify entity @s item.components."minecraft:custom_model_data".strings[0] set value "voting_no"
tag @s remove toggling_vote
