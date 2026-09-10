scoreboard players set @s use_carrot 0
execute at @s run playsound minecraft:entity.villager.work_librarian voice @s ~ ~ ~ 1 1
execute unless entity @s[tag=storyteller] run return 0
function ct:admin/setup/restore_saved
function ct:admin/setup/restore_variables
function ct:util/scores_to_variables
openguiscreen ct-bag
