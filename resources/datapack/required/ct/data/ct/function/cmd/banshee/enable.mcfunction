$tag $(player) add active_banshee
# $scoreboard players set $(player) vote_value 2
$tellraw @a[tag=storyteller] [{"text":"! ","color":"green","bold":true},{"translate":"clocktower.notice.banshee.ability_granted","color":"gray","bold":false,"with":[{"text":"$(player)"}]}]
