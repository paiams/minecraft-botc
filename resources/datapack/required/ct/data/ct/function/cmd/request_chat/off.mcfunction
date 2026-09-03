tellraw @s [{"text":"! ","color":"yellow","bold":true},{"translate":"clocktower.notice.request_chat.off","color":"gray","bold":false}]
tag @s[tag=requesting_chat] remove requesting_chat
fmvariable set requesting_chat false false
