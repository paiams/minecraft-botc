package dev.botc.names.mixin;

import com.mojang.brigadier.context.CommandContext;
import com.mojang.brigadier.context.ParsedArgument;
import com.mojang.brigadier.exceptions.CommandSyntaxException;
import net.minecraft.command.EntitySelector;
import net.minecraft.server.command.ServerCommandSource;
import net.minecraft.text.Text;
import java.util.Map;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Pseudo;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Pseudo
@Mixin(targets = "me.drex.meliuscommands.config.common.CommandAction", remap = false)
public abstract class MeliusCommandActionMixin {
    @Inject(method = "lambda$execute$1", at = @At("HEAD"), cancellable = true)
    private static void resolveDisplayName(Map<String, ParsedArgument<ServerCommandSource, ?>> arguments,
            CommandContext<ServerCommandSource> context, String id, CallbackInfoReturnable<Text> callback) {
        ParsedArgument<ServerCommandSource, ?> argument = arguments.get(id);
        if (argument == null || !(argument.getResult() instanceof EntitySelector selector)) return;
        // Resolve single-player selectors too; macros must never receive an alias or @s as a name.
        try {
            var players = selector.getPlayers(context.getSource());
            if (players.size() == 1) callback.setReturnValue(Text.literal(players.getFirst().getGameProfile().name()));
        } catch (CommandSyntaxException ignored) {
            // Keep Melius/vanilla's original error when the target is unavailable.
        }
    }
}
