execute unless score #test_active game_data matches 1 run return 0
execute if entity @a[tag=nominee] run return run schedule function botc_test:vote_done 1s replace
scoreboard players set #test_busy game_data 0
tellraw @a[tag=botc_test_controller] [{"text":"자동 투표 완료. 처형 예정자: ","color":"green"},{"selector":"@a[tag=marked_for_execution]"}]
execute as @a[tag=botc_test_controller] run function botc_test:menu
