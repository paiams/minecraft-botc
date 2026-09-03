scoreboard players set has_initialized game_data 1
tellraw @a [{"translate":"clocktower.tutorial.welcome"}]
tellraw @a [{"text":" "}]
tellraw @a [{"text":"• ","color":"white"},{"text":"/op ","color":"yellow"},{"selector":"@s","color":"yellow"},{"translate":"clocktower.tutorial.op_suffix","color":"white"}]
tellraw @a [{"text":"• ","color":"white"},{"translate":"clocktower.command.storyteller_add","color":"yellow"},{"selector":"@s","color":"yellow"},{"translate":"clocktower.tutorial.storyteller_suffix","color":"white"}]
tellraw @a [{"text":" "}]
tellraw @a [{"translate":"clocktower.tutorial.docs_prefix","color":"white",underlined:false},{"translate":"clocktower.tutorial.docs_link",underlined:true,color:"blue",click_event:{action:"open_url",url:"https://github.com/Sybillian/minecraft-botc/wiki"}},{"translate":"clocktower.tutorial.docs_suffix",underlined:false,color:white}]
