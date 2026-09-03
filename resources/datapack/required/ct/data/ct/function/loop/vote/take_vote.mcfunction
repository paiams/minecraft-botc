clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["voting_yes"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["voting_no"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["voting_banshee"]}]

tag @s add voting_now
execute if score organ_grinder settings matches 0 if entity @s[tag=voting_ghost,tag=dead] at @s run function ct:loop/vote/effect/ghost_vote
execute if score organ_grinder settings matches 0 if entity @s[tag=voting_banshee] at @s run function ct:loop/vote/effect/ghost_vote
execute if score organ_grinder settings matches 0 if entity @s[tag=voting_yes,tag=!dead] at @s run function ct:loop/vote/effect/regular_vote
tag @s remove voting_now

tag @s[tag=voting_ghost] add voted_today
tellraw @s[tag=voting_yes] {"translate":"clocktower.notice.voting.cast","with":[{"translate":"clocktower.vote.yes","color":"green"},{"selector":"@a[tag=nominee]"}]}
tellraw @s[tag=voting_ghost] {"translate":"clocktower.notice.voting.cast","with":[{"translate":"clocktower.vote.yes","color":"green"},{"selector":"@a[tag=nominee]"}]}
tellraw @s[tag=voting_banshee] {"translate":"clocktower.notice.voting.cast","with":[{"translate":"clocktower.vote.yes","color":"aqua"},{"selector":"@a[tag=nominee]"}]}
tellraw @s[tag=voting_no] {"translate":"clocktower.notice.voting.cast","with":[{"translate":"clocktower.vote.no","color":"red"},{"selector":"@a[tag=nominee]"}]}

function ct:admin/variables/score
