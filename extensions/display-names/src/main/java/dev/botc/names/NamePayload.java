package dev.botc.names;

import net.minecraft.network.RegistryByteBuf;
import net.minecraft.network.codec.PacketCodec;
import net.minecraft.network.packet.CustomPayload;
import net.minecraft.util.Identifier;
import java.util.UUID;

public record NamePayload(UUID uuid, String accountName, String displayName) implements CustomPayload {
    public static final Id<NamePayload> ID = new Id<>(Identifier.of("botc_display_names", "name"));
    public static final PacketCodec<RegistryByteBuf, NamePayload> CODEC = new PacketCodec<>() {
        public NamePayload decode(RegistryByteBuf buf) {
            return new NamePayload(buf.readUuid(), buf.readString(16), buf.readString(128));
        }
        public void encode(RegistryByteBuf buf, NamePayload value) {
            buf.writeUuid(value.uuid());
            buf.writeString(value.accountName(), 16);
            buf.writeString(value.displayName(), 128);
        }
    };
    public Id<? extends CustomPayload> getId() { return ID; }
}
