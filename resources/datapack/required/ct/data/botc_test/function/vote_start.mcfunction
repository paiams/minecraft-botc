execute unless score #test_active game_data matches 1 run return 0
execute unless entity @a[tag=nominee] run return run scoreboard players set #test_busy game_data 0
execute as @a[tag=botc_test_controller,limit=1] at @s run function ct:loop/vote/start_vote
schedule function botc_test:vote_done 4s replace
