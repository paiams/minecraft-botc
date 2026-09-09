# Run manually on a test server: function ct:script/test_night_order_upgrade
# Preserve the selected script while checking legacy, blank, and custom entries.
data modify storage ct:night_order_test saved set from storage ct:script {}
data modify storage ct:script night_order set value {first:[{id:"washerwoman",first_night_hint:"keep"},{id:"none"},{id:"custom_role",first_night_hint:"custom"}],other:[{id:"monk",other_nights_hint:"keep"},{id:"none"}]}
function ct:script/localize_night_order
execute unless data storage ct:script night_order.first[{id:"washerwoman",first_night_key:"clocktower.role.washerwoman.first_night",localized:"yes",first_night_hint:"keep"}] run return run function ct:script/test_night_order_upgrade_fail
execute unless data storage ct:script night_order.first[{id:"none",first_night_key:"",localized:"no"}] run return run function ct:script/test_night_order_upgrade_fail
execute unless data storage ct:script night_order.first[{id:"custom_role",first_night_key:"",localized:"no",first_night_hint:"custom"}] run return run function ct:script/test_night_order_upgrade_fail
execute unless data storage ct:script night_order.other[{id:"monk",other_night_key:"clocktower.role.monk.other_night",localized:"yes",other_nights_hint:"keep"}] run return run function ct:script/test_night_order_upgrade_fail
execute unless data storage ct:script night_order.other[{id:"none",other_night_key:"",localized:"no"}] run return run function ct:script/test_night_order_upgrade_fail
data modify storage ct:night_order_test once set from storage ct:script night_order
function ct:script/localize_night_order
execute store success storage ct:night_order_test changed byte 1 run data modify storage ct:night_order_test once set from storage ct:script night_order
execute if data storage ct:night_order_test {changed:1b} run return run function ct:script/test_night_order_upgrade_fail
data modify storage ct:script {} set from storage ct:night_order_test saved
data remove storage ct:night_order_test saved
data remove storage ct:night_order_test once
data remove storage ct:night_order_test changed
say NIGHT_ORDER_UPGRADE_PASS
