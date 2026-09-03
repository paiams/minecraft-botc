tag @s add universal_vc
tellraw @s [{text:"! ",color:green,bold:true},{translate:"clocktower.voicechat.night_chat",color:gray,bold:false,with:[{translate:"clocktower.voicechat.joined",color:green,bold:false}]}]
voicechat join "Night Chat" ct
