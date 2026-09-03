$execute if entity @s[tag=!storyteller] run tellraw @s {"translate":"clocktower.notice.storyteller.already_removed","with":[{"text":"$(target)"}]}
$execute if entity @s[tag=storyteller] run tellraw @s {"translate":"clocktower.notice.storyteller.removed","with":[{"text":"$(target)"}]}

execute if entity @s[tag=storyteller] run team leave @s
fmvariable set storyteller false false
tag @s remove storyteller
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["ct_bag"]}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["start_vote"]}]
