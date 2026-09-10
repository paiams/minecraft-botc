execute unless entity @s[tag=storyteller] run return 0
tellraw @s {"text":"[BotC 테스트] 실제 참가자 없이 이야기꾼 혼자 사용하세요.","color":"gold"}
tellraw @s [{"text":"[8인 준비] ","color":"aqua","click_event":{"action":"run_command","command":"/botc_test setup"}},{"text":"[첫날 낮까지] ","color":"aqua","click_event":{"action":"run_command","command":"/botc_test day"}},{"text":"[종료]","color":"red","click_event":{"action":"run_command","command":"/botc_test stop"}}]
tellraw @s [{"text":"[3표 미달] ","color":"aqua","click_event":{"action":"run_command","command":"/botc_test vote 3 2"}},{"text":"[4표 과반] ","color":"aqua","click_event":{"action":"run_command","command":"/botc_test vote 4 2"}},{"text":"[4표 동률] ","color":"aqua","click_event":{"action":"run_command","command":"/botc_test vote 4 3"}},{"text":"[5표 역전]","color":"aqua","click_event":{"action":"run_command","command":"/botc_test vote 5 4"}}]
tellraw @s {"text":"직접 지정: /botc_test vote <찬성 0~8> <지목 좌석 1~8> | 집 이동은 빠른 작업 메뉴에서 확인","color":"gray"}
