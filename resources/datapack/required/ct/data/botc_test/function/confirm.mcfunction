execute unless entity @s[tag=storyteller] run return 0
tellraw @s [{"text":"현재 게임을 초기화하고 가상 참가자 8명과 테스트용 역할을 배치합니다. ","color":"yellow"},{"text":"[초기화 및 8인 준비]","color":"red","click_event":{"action":"run_command","command":"/botc_test setup confirm"}}]
