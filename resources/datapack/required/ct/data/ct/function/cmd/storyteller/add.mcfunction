$execute if entity @s[tag=!storyteller] run tellraw @a[tag=storyteller] {"translate":"clocktower.notice.storyteller.added","with":[{"text":"$(target)"}]}
execute if entity @s[tag=!storyteller] run tellraw @s {"translate":"clocktower.notice.storyteller.added_self"}
$execute if entity @s[tag=storyteller] run tellraw @a[tag=storyteller] {"translate":"clocktower.notice.storyteller.already","with":[{"text":"$(target)"}]}

execute if entity @s[tag=!storyteller] run team join 99_storyteller @s
fmvariable set storyteller false true
tag @s add storyteller
function ct:admin/give_script
