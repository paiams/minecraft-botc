$execute if data storage ct:character_data characters.$(id).first_night_key run data modify storage ct:script night_order.first[{id:"$(id)"}].first_night_key set from storage ct:character_data characters.$(id).first_night_key
$execute if data storage ct:character_data characters.$(id).first_night_key run data modify storage ct:script night_order.first[{id:"$(id)"}].localized set value "yes"
$execute if data storage ct:character_data characters.$(id).other_night_key run data modify storage ct:script night_order.other[{id:"$(id)"}].other_night_key set from storage ct:character_data characters.$(id).other_night_key
$execute if data storage ct:character_data characters.$(id).other_night_key run data modify storage ct:script night_order.other[{id:"$(id)"}].localized set value "yes"
data remove storage ct:night_order_upgrade pending[0]
execute if data storage ct:night_order_upgrade pending[0] run function ct:script/localize_night_order_entry with storage ct:night_order_upgrade pending[0]
