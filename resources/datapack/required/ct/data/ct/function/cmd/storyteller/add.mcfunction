$execute if entity @s[tag=!storyteller] run tellraw @a[tag=storyteller] {"translate":"clocktower.notice.storyteller.added","with":[{"selector":"@a[name=$(target)]"}]}
execute if entity @s[tag=!storyteller] run tellraw @s {"translate":"clocktower.notice.storyteller.added_self"}
$execute if entity @s[tag=storyteller] run tellraw @a[tag=storyteller] {"translate":"clocktower.notice.storyteller.already","with":[{"selector":"@a[name=$(target)]"}]}

execute if entity @s[tag=!storyteller] run team join 99_storyteller @s
fmvariable set storyteller false true
tag @s add storyteller
function ct:admin/give_script
