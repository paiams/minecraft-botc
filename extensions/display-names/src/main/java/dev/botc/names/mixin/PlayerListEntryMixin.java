package dev.botc.names.mixin;

import dev.botc.names.DisplayNames;
import net.minecraft.client.network.PlayerListEntry;
import net.minecraft.scoreboard.Team;
import net.minecraft.text.Text;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(PlayerListEntry.class)
public abstract class PlayerListEntryMixin {
    @Inject(method = "getDisplayName", at = @At("RETURN"), cancellable = true)
    private void displayName(CallbackInfoReturnable<Text> callback) {
        PlayerListEntry entry = (PlayerListEntry) (Object) this;
        String name = DisplayNames.displayName(entry.getProfile().id(), true);
        if (name != null) callback.setReturnValue(Team.decorateName(entry.getScoreboardTeam(), Text.literal(name)));
    }
}
