package dev.botc.names;

import java.util.UUID;

public final class DisplayNamesCheck {
    public static void main(String[] args) {
        for (String name : new String[]{"철수", "山田太郎", "王小明", "Élodie", "Αλέξανδρος", "Мария", "ليلى", "अनन्या", "João Silva", "Player_2", "🧑‍🚀"}) {
            assert NameRules.normalize(name).equals(name) : name;
        }
        assert NameRules.normalize("  E\u0301lodie  ").equals("Élodie");
        assert NameRules.key("Ｐｌａｙｅｒ").equals(NameRules.key("player"));
        for (String name : new String[]{"", "   ", "a".repeat(33), "\u200D", "@a", "{player}", "name\ncommand", "name\u202E", "%n%", "§cAdmin", "name;op", "name\""}) {
            try {
                NameRules.normalize(name);
                throw new AssertionError("Accepted unsafe name: " + name);
            } catch (IllegalArgumentException expected) { }
        }
        UUID player = UUID.randomUUID();
        DisplayNames.receive(new NamePayload(player, "PlayerOne", "Élodie"));
        assert DisplayNames.displayName(player, true).equals("Élodie");
        assert DisplayNames.clientDisplayName("playerone").equals("Élodie");
        assert DisplayNames.resolveAccount("E\u0301LODIE").equals("PlayerOne");
        assert DisplayNames.resolveAccount("PlayerOne").equals("PlayerOne");
        assert DisplayNames.resolveAccount("@a") == null;
        DisplayNames.receive(new NamePayload(player, "PlayerOne", "山田太郎"));
        assert DisplayNames.resolveAccount("Élodie") == null;
        assert DisplayNames.clientDisplayName("PlayerOne").equals("山田太郎");
        DisplayNames.receive(new NamePayload(player, "PlayerOne", ""));
        assert DisplayNames.displayName(player, true) == null;
        assert DisplayNames.clientDisplayName("PlayerOne").equals("PlayerOne");
        assert DisplayNames.clientDisplayName(player, "Old cached voice name").equals("PlayerOne");
        DisplayNames.clearClient();
        assert DisplayNames.resolveAccount("PlayerOne") == null;
        assert DisplayNames.clientDisplayName("Nobody!").equals("Nobody!");
        assert DisplayNames.clientDisplayName(player, "Other server name").equals("Other server name");
        System.out.println("Display-name validation and client synchronization: PASS");
    }
}
