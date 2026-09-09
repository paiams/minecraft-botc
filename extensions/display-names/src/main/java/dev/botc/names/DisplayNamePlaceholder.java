package dev.botc.names;

import de.keksuccino.fancymenu.customization.placeholder.DeserializedPlaceholderString;
import de.keksuccino.fancymenu.customization.placeholder.Placeholder;
import de.keksuccino.fancymenu.customization.placeholder.PlaceholderRegistry;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

public final class DisplayNamePlaceholder extends Placeholder {
    private DisplayNamePlaceholder() { super("display_name"); }
    public static void register() { PlaceholderRegistry.register(new DisplayNamePlaceholder()); }
    public boolean canRunAsync() { return true; }
    public String getReplacementFor(DeserializedPlaceholderString value) {
        return DisplayNames.clientDisplayName(value.values.getOrDefault("account_name", ""));
    }
    public List<String> getValueNames() { return List.of("account_name"); }
    public String getDisplayName() { return "Player Display Name"; }
    public List<String> getDescription() { return List.of("Display name for an account; falls back to the account name."); }
    public String getCategory() { return "Blood on the Clocktower"; }
    public DeserializedPlaceholderString getDefaultPlaceholderString() {
        return new DeserializedPlaceholderString(getIdentifier(), new HashMap<>(Map.of("account_name", "Player")),
                "{\"placeholder\":\"display_name\",\"values\":{\"account_name\":\"Player\"}}");
    }
}
