say take vote
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["voting_yes"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["voting_no"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["voting_banshee"]}]

tag @s add voting_now
execute as @s[tag=dead,tag=voting_ghost] run function ct:vote/effect/ghost_vote
execute as @s[tag=!dead,tag=voting_yes] at @s run function ct:vote/effect/single_vote
scoreboard players operation total vote += @s vote_value
tag @s remove voting_now

tellraw @s[tag=voting_yes] {"translate":"clocktower.notice.voting.cast","with":[{"translate":"clocktower.vote.yes","color":"green"},{"selector":"@a[tag=nominee]"}]}
tellraw @s[tag=voting_ghost] {"translate":"clocktower.notice.voting.cast","with":[{"translate":"clocktower.vote.yes","color":"green"},{"selector":"@a[tag=nominee]"}]}
tellraw @s[tag=voting_banshee] {"translate":"clocktower.notice.voting.cast","with":[{"translate":"clocktower.vote.yes","color":"aqua"},{"selector":"@a[tag=nominee]"}]}
tellraw @s[tag=voting_no] {"translate":"clocktower.notice.voting.cast","with":[{"translate":"clocktower.vote.no","color":"red"},{"selector":"@a[tag=nominee]"}]}

function ct:admin/variables/score
function ct:util/sync_variables
