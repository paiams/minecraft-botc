package dev.botc.names.mixin;

import com.mojang.brigadier.StringReader;
import com.mojang.brigadier.exceptions.CommandSyntaxException;
import dev.botc.names.DisplayNames;
import net.minecraft.command.EntitySelectorReader;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Shadow;
import org.spongepowered.asm.mixin.Final;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(EntitySelectorReader.class)
public abstract class EntitySelectorReaderMixin {
    @Shadow @Final private StringReader reader;
    @Shadow private String playerName;
    @Shadow private boolean includesNonPlayers;
    @Shadow private int limit;

    @Inject(method = "readRegular", at = @At("HEAD"), cancellable = true)
    private void readDisplayName(CallbackInfo callback) throws CommandSyntaxException {
        int start = reader.getCursor();
        String input;
        if (reader.canRead() && StringReader.isQuotedStringStart(reader.peek())) {
            input = reader.readString();
        } else {
            while (reader.canRead() && !Character.isWhitespace(reader.peek())) reader.skip();
            input = reader.getString().substring(start, reader.getCursor());
        }
        String account = DisplayNames.resolveAccount(input);
        if (account != null) {
            playerName = account;
            includesNonPlayers = false;
            limit = 1;
            callback.cancel();
            return;
        }
        // Unrecognized input keeps vanilla parsing and error behavior.
        reader.setCursor(start);
    }
}
