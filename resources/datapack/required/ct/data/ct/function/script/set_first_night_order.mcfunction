$execute if data storage ct:character_data characters.$(char).first run data modify storage ct:script night_order.first append value {id:$(char)}
$execute if data storage ct:character_data characters.$(char).first run data modify storage ct:script night_order.first[{id:$(char)}].first_night_hint set from storage ct:character_data characters.$(char).first
$execute if data storage ct:character_data characters.$(char).first_night_key run data modify storage ct:script night_order.first[{id:$(char)}].first_night_key set from storage ct:character_data characters.$(char).first_night_key
$execute if data storage ct:character_data characters.$(char).first_night_key run data modify storage ct:script night_order.first[{id:$(char)}].localized set value "yes"
