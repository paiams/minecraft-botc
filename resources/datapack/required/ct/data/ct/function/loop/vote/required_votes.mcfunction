function ct:admin/variables/score
scoreboard players operation majority math = alive_players game_data
scoreboard players operation modulo math = alive_players game_data
scoreboard players operation majority math /= half math
scoreboard players operation modulo math %= half math
scoreboard players operation majority math += modulo math
scoreboard players operation #required vote = majority math
execute if score current_majority vote > #required vote run scoreboard players operation #required vote = current_majority vote
