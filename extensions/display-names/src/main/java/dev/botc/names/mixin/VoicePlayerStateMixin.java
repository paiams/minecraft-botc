package dev.botc.names.mixin;

import dev.botc.names.DisplayNames;
import java.util.UUID;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Pseudo;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Pseudo
@Mixin(targets = "de.maxhenkel.voicechat.voice.common.PlayerState", remap = false)
public abstract class VoicePlayerStateMixin {
    @Shadow private UUID uuid;
    @Inject(method = "getName", at = @At("RETURN"), cancellable = true)
    private void displayName(CallbackInfoReturnable<String> callback) {
        // Offline volume entries can contain a cached old nickname after a reset.
        callback.setReturnValue(DisplayNames.clientDisplayName(uuid, callback.getReturnValue()));
    }
}
