execute if score @s[tag=!storyteller,tag=!spectator,tag=universal_vc] vc = @s id run title @s actionbar {"translate":"clocktower.voicechat.status","color":"white","with":[{"translate":"clocktower.voicechat.status_everyone","color":"green"}]}
execute if score @s[tag=!storyteller,tag=!spectator,tag=!universal_vc] vc = @s id run title @s actionbar {"translate":"clocktower.voicechat.status","color":"white","with":[{"translate":"clocktower.voicechat.status_storyteller","color":"red"}]}

execute as @s[tag=storyteller,tag=universal_vc] unless entity @a[tag=!storyteller,tag=!spectator,scores={vc=0}] run title @s actionbar {"translate":"clocktower.voicechat.status","color":"white","with":[{"translate":"clocktower.voicechat.status_everyone","color":"green"}]}
execute as @s[tag=storyteller,tag=!universal_vc] unless entity @a[tag=!storyteller,tag=!spectator,scores={vc=0}] run title @s actionbar {"translate":"clocktower.voicechat.status","color":"white","with":[{"translate":"clocktower.voicechat.status_local","color":"red"}]}

execute as @s[tag=spectator,tag=universal_vc] run title @s actionbar {"translate":"clocktower.voicechat.listening","color":"white","with":[{"translate":"clocktower.voicechat.listening_night","color":"green"}]}
execute as @s[tag=spectator,tag=!universal_vc] run title @s actionbar {"translate":"clocktower.voicechat.listening","color":"white","with":[{"translate":"clocktower.voicechat.listening_local","color":"red"}]}
