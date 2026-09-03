execute if entity @a[scores={rps=1},tag=playing_rps] run tellraw @a {"translate":"clocktower.rps.chose","with":[{"selector":"@a[scores={rps=1},tag=playing_rps]"},{"translate":"clocktower.rps.rock"}]}
execute if entity @a[scores={rps=2},tag=playing_rps] run tellraw @a {"translate":"clocktower.rps.chose","with":[{"selector":"@a[scores={rps=2},tag=playing_rps]"},{"translate":"clocktower.rps.paper"}]}
execute if entity @a[scores={rps=3},tag=playing_rps] run tellraw @a {"translate":"clocktower.rps.chose","with":[{"selector":"@a[scores={rps=3},tag=playing_rps]"},{"translate":"clocktower.rps.scissors"}]}

scoreboard players reset @a rps
tag @a remove playing_rps
