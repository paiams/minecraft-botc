tellraw @s [{"text":"! ","color":"yellow","bold":true},{"translate":"clocktower.notice.request_chat.on","color":"gray","bold":false}]
tag @s[tag=!requesting_chat] add requesting_chat
fmvariable set requesting_chat false true
