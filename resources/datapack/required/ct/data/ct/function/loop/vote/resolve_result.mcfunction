# current_majority is the previous highest vote count plus one.
execute unless entity @a[tag=nominee] run return 0
scoreboard players operation #required vote = current_majority vote
execute if score current_majority vote matches 0 run scoreboard players operation #required vote = majority math
scoreboard players operation #previous vote = current_majority vote
scoreboard players remove #previous vote 1
execute if score current_majority vote matches 1.. if score total vote = #previous vote run return run tag @a remove marked_for_execution
execute if score total vote < #required vote run return 0
tag @a remove marked_for_execution
tag @a[tag=nominee] add marked_for_execution
function ct:loop/vote/set_majority
