package dev.botc.names;

import net.fabricmc.api.ClientModInitializer;
import net.fabricmc.loader.api.FabricLoader;
import net.fabricmc.fabric.api.client.networking.v1.ClientPlayConnectionEvents;
import net.fabricmc.fabric.api.client.networking.v1.ClientPlayNetworking;

public final class DisplayNamesClient implements ClientModInitializer {
    public void onInitializeClient() {
        ClientPlayNetworking.registerGlobalReceiver(NamePayload.ID, (payload, context) ->
                context.client().execute(() -> DisplayNames.receive(payload)));
        ClientPlayConnectionEvents.INIT.register((handler, client) -> DisplayNames.clearClient());
        ClientPlayConnectionEvents.DISCONNECT.register((handler, client) -> DisplayNames.clearClient());
        if (FabricLoader.getInstance().isModLoaded("fancymenu")) DisplayNamePlaceholder.register();
    }
}
