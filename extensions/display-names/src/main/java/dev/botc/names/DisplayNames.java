package dev.botc.names;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mojang.brigadier.arguments.StringArgumentType;
import com.mojang.brigadier.exceptions.CommandSyntaxException;
import com.mojang.brigadier.exceptions.SimpleCommandExceptionType;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerLifecycleEvents;
import net.fabricmc.fabric.api.networking.v1.PayloadTypeRegistry;
import net.fabricmc.fabric.api.networking.v1.ServerPlayConnectionEvents;
import net.fabricmc.fabric.api.networking.v1.ServerPlayNetworking;
import net.minecraft.command.argument.EntityArgumentType;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.command.ServerCommandSource;
import net.minecraft.server.network.ServerPlayerEntity;
import net.minecraft.text.Text;
import net.minecraft.util.WorldSavePath;

import java.io.IOException;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import static net.minecraft.server.command.CommandManager.*;

public final class DisplayNames implements ModInitializer {
    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().disableHtmlEscaping().create();
    private static volatile MinecraftServer server;
    private static volatile Map<UUID, NamePayload> serverNames = Map.of();
    private static volatile Map<UUID, NamePayload> clientNames = Map.of();
    private static Path saveFile;

    public void onInitialize() {
        PayloadTypeRegistry.playS2C().register(NamePayload.ID, NamePayload.CODEC);
        ServerLifecycleEvents.SERVER_STARTING.register(instance -> {
            server = instance;
            saveFile = instance.getSavePath(WorldSavePath.ROOT).resolve("data/botc-display-names.json");
            serverNames = load(saveFile);
        });
        ServerLifecycleEvents.SERVER_STOPPED.register(instance -> {
            serverNames = Map.of();
            server = null;
        });
        ServerPlayConnectionEvents.JOIN.register((handler, sender, instance) -> {
            ServerPlayerEntity player = handler.player;
            UUID uuid = player.getUuid();
            String account = player.getGameProfile().name();
            NamePayload old = serverNames.get(uuid);
            Map<UUID, NamePayload> updated = new HashMap<>(serverNames);
            updated.put(uuid, new NamePayload(uuid, account, old == null ? "" : old.displayName()));
            // An actual account always wins if its owner joins after someone claimed that alias.
            updated.replaceAll((id, entry) -> !id.equals(uuid) && NameRules.key(entry.displayName()).equals(NameRules.key(account))
                    ? new NamePayload(id, entry.accountName(), "") : entry);
            try {
                if (!updated.equals(serverNames)) commit(updated);
                for (NamePayload entry : serverNames.values()) send(player, entry);
            } catch (IOException error) {
                instance.sendMessage(Text.literal("Could not save display names: " + error.getMessage()));
                handler.disconnect(Text.literal("Display-name data could not be saved. Please contact the server owner."));
            }
        });
        CommandRegistrationCallback.EVENT.register((dispatcher, access, environment) -> dispatcher.register(
                literal("displayname")
                        .then(literal("set").then(argument("display_name", StringArgumentType.greedyString())
                                .executes(ctx -> change(ctx.getSource(), ctx.getSource().getPlayerOrThrow(), StringArgumentType.getString(ctx, "display_name")))))
                        .then(literal("reset").executes(ctx -> change(ctx.getSource(), ctx.getSource().getPlayerOrThrow(), "")))
                        .then(literal("setfor").requires(requirePermissionLevel(GAMEMASTERS_CHECK))
                                .then(argument("player", EntityArgumentType.player())
                                        .then(argument("display_name", StringArgumentType.greedyString())
                                                .executes(ctx -> change(ctx.getSource(), EntityArgumentType.getPlayer(ctx, "player"), StringArgumentType.getString(ctx, "display_name"))))))
                        .then(literal("resetfor").requires(requirePermissionLevel(GAMEMASTERS_CHECK))
                                .then(argument("player", EntityArgumentType.player())
                                        .executes(ctx -> change(ctx.getSource(), EntityArgumentType.getPlayer(ctx, "player"), ""))))));
    }

    private static int change(ServerCommandSource source, ServerPlayerEntity player, String input) throws CommandSyntaxException {
        try {
            String name = input.isEmpty() ? "" : NameRules.normalize(input);
            String key = NameRules.key(name);
            for (NamePayload entry : serverNames.values()) {
                if (!name.isEmpty() && !entry.uuid().equals(player.getUuid())
                        && (key.equals(NameRules.key(entry.accountName())) || key.equals(NameRules.key(entry.displayName())))) {
                    throw new IllegalArgumentException("That display name is already used by another player.");
                }
            }
            Map<UUID, NamePayload> updated = new HashMap<>(serverNames);
            updated.put(player.getUuid(), new NamePayload(player.getUuid(), player.getGameProfile().name(), name));
            commit(updated);
            source.sendFeedback(() -> Text.literal("Display name for " + player.getGameProfile().name() + ": "
                    + (name.isEmpty() ? player.getGameProfile().name() : name)), false);
            return 1;
        } catch (IllegalArgumentException | IOException error) {
            throw new SimpleCommandExceptionType(Text.literal(error.getMessage())).create();
        }
    }

    private static Map<UUID, NamePayload> load(Path path) {
        if (!Files.exists(path)) return Map.of();
        try (Reader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
            NamePayload[] entries = GSON.fromJson(reader, NamePayload[].class);
            if (entries == null) throw new IllegalArgumentException("Expected a display-name array");
            Map<UUID, NamePayload> result = new HashMap<>();
            for (NamePayload entry : entries) {
                if (entry == null || entry.uuid() == null || entry.accountName() == null
                        || !entry.accountName().matches("[A-Za-z0-9_]{1,16}") || entry.displayName() == null) {
                    throw new IllegalArgumentException("Invalid display-name record");
                }
                String name = entry.displayName().isEmpty() ? "" : NameRules.normalize(entry.displayName());
                if (result.put(entry.uuid(), new NamePayload(entry.uuid(), entry.accountName(), name)) != null) {
                    throw new IllegalArgumentException("Duplicate player UUID");
                }
            }
            return Map.copyOf(result);
        } catch (IOException | RuntimeException error) {
            // Refuse to overwrite malformed data with an empty registry.
            throw new IllegalStateException("Cannot read " + path + "; repair or restore it before starting the server", error);
        }
    }

    private static void commit(Map<UUID, NamePayload> updated) throws IOException {
        Files.createDirectories(saveFile.getParent());
        Path temporary = Files.createTempFile(saveFile.getParent(), "display-names-", ".tmp");
        try {
            Files.writeString(temporary, GSON.toJson(updated.values()), StandardCharsets.UTF_8);
            try {
                Files.move(temporary, saveFile, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
            } catch (AtomicMoveNotSupportedException error) {
                Files.move(temporary, saveFile, StandardCopyOption.REPLACE_EXISTING);
            }
        } finally {
            Files.deleteIfExists(temporary);
        }
        Map<UUID, NamePayload> previous = serverNames;
        serverNames = Map.copyOf(updated);
        for (NamePayload entry : serverNames.values()) {
            if (!entry.equals(previous.get(entry.uuid()))) {
                for (ServerPlayerEntity player : server.getPlayerManager().getPlayerList()) send(player, entry);
            }
        }
    }

    private static void send(ServerPlayerEntity player, NamePayload entry) {
        if (ServerPlayNetworking.canSend(player, NamePayload.ID)) ServerPlayNetworking.send(player, entry);
    }

    public static void receive(NamePayload entry) {
        Map<UUID, NamePayload> updated = new HashMap<>(clientNames);
        updated.put(entry.uuid(), entry);
        clientNames = Map.copyOf(updated);
    }

    public static void clearClient() { clientNames = Map.of(); }

    public static String displayName(UUID uuid, boolean client) {
        NamePayload entry = (client ? clientNames : serverNames).get(uuid);
        return entry == null || entry.displayName().isEmpty() ? null : entry.displayName();
    }

    public static String clientDisplayName(String accountName) {
        for (NamePayload entry : clientNames.values()) {
            if (entry.accountName().equalsIgnoreCase(accountName) && !entry.displayName().isEmpty()) return entry.displayName();
        }
        return accountName;
    }

    public static String clientDisplayName(UUID uuid, String fallback) {
        NamePayload entry = clientNames.get(uuid);
        if (entry == null) return fallback;
        return entry.displayName().isEmpty() ? entry.accountName() : entry.displayName();
    }

    public static String resolveAccount(String input) {
        Map<UUID, NamePayload> names = server != null && server.isOnThread() ? serverNames : clientNames;
        for (NamePayload entry : names.values()) {
            if (entry.accountName().equalsIgnoreCase(input)) return entry.accountName();
        }
        String key = NameRules.key(input);
        for (NamePayload entry : names.values()) {
            if (!entry.displayName().isEmpty() && NameRules.key(entry.displayName()).equals(key)) return entry.accountName();
        }
        return null;
    }
}
