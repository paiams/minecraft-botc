tag @s remove universal_vc
voicechat leave
scoreboard players set @s vc 0
tellraw @s [{text:"! ",color:red,bold:true},{translate:"clocktower.voicechat.night_chat",color:gray,bold:false,with:[{translate:"clocktower.voicechat.exited",color:red,bold:false}]}]
