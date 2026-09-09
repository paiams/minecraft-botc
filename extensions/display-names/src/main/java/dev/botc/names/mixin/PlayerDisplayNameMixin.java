package dev.botc.names.mixin;

import dev.botc.names.DisplayNames;
import net.minecraft.entity.player.PlayerEntity;
import net.minecraft.text.Text;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.ModifyArg;

@Mixin(PlayerEntity.class)
public abstract class PlayerDisplayNameMixin {
    // Only replace the label. Vanilla retains team formatting, account hover and click actions.
    @ModifyArg(method = "getDisplayName", at = @At(value = "INVOKE", target = "Lnet/minecraft/scoreboard/Team;decorateName(Lnet/minecraft/scoreboard/AbstractTeam;Lnet/minecraft/text/Text;)Lnet/minecraft/text/MutableText;"), index = 1)
    private Text displayName(Text original) {
        PlayerEntity player = (PlayerEntity) (Object) this;
        String name = DisplayNames.displayName(player.getUuid(), player.getEntityWorld().isClient());
        return name == null ? original : Text.literal(name);
    }
}
