data modify storage ct:script {} set from storage ct:night_order_test saved
data remove storage ct:night_order_test saved
say NIGHT_ORDER_UPGRADE_FAIL
return fail
