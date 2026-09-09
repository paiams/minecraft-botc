package dev.botc.names;

import java.text.Normalizer;
import java.util.Locale;

public final class NameRules {
    private NameRules() {}

    public static String normalize(String input) {
        String name = Normalizer.normalize(input.strip(), Normalizer.Form.NFC);
        if (name.isEmpty() || name.codePointCount(0, name.length()) > 32) {
            throw new IllegalArgumentException("Use 1–32 characters for a display name.");
        }
        // Menu markup and command delimiters are never accepted as player text.
        if (!name.codePoints().allMatch(c -> Character.isLetterOrDigit(c)
                || Character.getType(c) == Character.NON_SPACING_MARK
                || Character.getType(c) == Character.COMBINING_SPACING_MARK
                || Character.getType(c) == Character.OTHER_SYMBOL
                || Character.getType(c) == Character.MODIFIER_SYMBOL
                || c == 0x200C || c == 0x200D || " -_.'’".indexOf(c) >= 0)) {
            throw new IllegalArgumentException("Use letters, numbers, combining marks, emoji, spaces, hyphens, underscores, periods or apostrophes.");
        }
        if (name.codePoints().noneMatch(c -> Character.isLetterOrDigit(c)
                || Character.getType(c) == Character.OTHER_SYMBOL)) {
            throw new IllegalArgumentException("A display name must contain a visible letter, number or symbol.");
        }
        return name;
    }

    public static String key(String name) {
        return Normalizer.normalize(name, Normalizer.Form.NFKC).toLowerCase(Locale.ROOT);
    }
}
