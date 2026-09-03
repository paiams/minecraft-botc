$tag $(player) remove active_banshee
$scoreboard players set $(player) vote_value 1
$tellraw @a[tag=storyteller] [{"text":"! ","color":"red","bold":true},{"translate":"clocktower.notice.banshee.ability_revoked","color":"gray","bold":false,"with":[{"text":"$(player)"}]}]
