$execute if data storage ct:character_data characters.$(char).other run data modify storage ct:script night_order.other append value {id:$(char)}
$execute if data storage ct:character_data characters.$(char).other run data modify storage ct:script night_order.other[{id:$(char)}].other_nights_hint set from storage ct:character_data characters.$(char).other
$execute if data storage ct:character_data characters.$(char).other_night_key run data modify storage ct:script night_order.other[{id:$(char)}].other_night_key set from storage ct:character_data characters.$(char).other_night_key
$execute if data storage ct:character_data characters.$(char).other_night_key run data modify storage ct:script night_order.other[{id:$(char)}].localized set value "yes"
