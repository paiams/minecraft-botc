# Upgrade saved night orders without rebuilding the selected script or its hints.
# This also runs in dev mode, where the normal initialization is skipped.
function ct:data/character_data
data modify storage ct:script night_order.first[].first_night_key set value ""
data modify storage ct:script night_order.first[].localized set value "no"
data modify storage ct:script night_order.other[].other_night_key set value ""
data modify storage ct:script night_order.other[].localized set value "no"
data modify storage ct:night_order_upgrade pending set value []
data modify storage ct:night_order_upgrade pending append from storage ct:script night_order.first[]
data modify storage ct:night_order_upgrade pending append from storage ct:script night_order.other[]
execute if data storage ct:night_order_upgrade pending[0] run function ct:script/localize_night_order_entry with storage ct:night_order_upgrade pending[0]
data remove storage ct:night_order_upgrade pending
