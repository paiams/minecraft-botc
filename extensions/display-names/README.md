# BotC Display Names

A Fabric 1.21.11 extension for player display names across writing systems.
The server stores names by UUID in `world/data/botc-display-names.json` and sends
them to clients. It never changes game profiles, scoreboard identities, skins,
seat assignments, voice connections or the account identifiers in FancyMenu variables.

## Use

Install `botc-display-names-1.0.0.jar` on **both the server and every client**,
together with the updated pack configuration and datapack. Stop and back up
existing runtimes before installing. The menus require this extension.

```text
/displayname set Élodie
/displayname set 山田太郎
/displayname set João Silva
/displayname reset
```

Players can set/reset their own name. Operators with gamemaster permissions can
use `/displayname setfor <player> <display_name>` and `/displayname resetfor <player>`.
Names accept 1–32 Unicode code points after trimming and NFC normalization:
letters, digits, combining marks, emoji, ordinary spaces, hyphens, underscores,
periods and apostrophes. Formatting/command delimiters and control characters are
rejected. Rendering still depends on Minecraft's font and bidirectional-text support.
Language-specific shaping and additional fonts are not supplied by this mod.

Aliases are compared with NFKC normalization and locale-independent lowercase.
Another player's known account name or display name cannot be claimed. Actual
accounts take precedence; an alias conflicting with a newly joining account is
cleared. Unset names fall back to the account name. Persistence is world-specific;
client data is cleared on disconnect. Do not include the saved registry in releases.

Recognized display names work in player arguments, including `/point`,
`/whisper`, `/set_nominee` and `/set_nominator`. Quote names containing spaces:

```text
/point 山田太郎
/whisper "João Silva" Hello
```

Account names and vanilla selectors remain valid. Autocomplete still offers
account names. Selectors such as `@a[name=Steve123]` always use account names.

## Integration boundaries

- Vanilla display names retain team decoration and the original account hover/click
  actions. Chat, name tags and selector-based vote messages share this path.
- The tab list uses the synchronized display name with team decoration.
- FancyMenu uses `{"placeholder":"display_name","values":{"account_name":"..."}}`
  only in visible text. `player_1`…`player_15`, action commands, skin URLs,
  nomination storage and `last_nom` keep account names. The placeholder resolves
  the latest display name when rendered, including after a name change.
- Melius Commands receives a resolved account name for single-player entity arguments;
  arbitrary message text is never interpreted as an alias.
- Simple Voice Chat's client `PlayerState.getName()` uses the same UUID lookup
  for group/HUD/volume labels. Voice transport, skins and volume ownership retain UUIDs.

Compatibility targets are the pack's pinned FancyMenu 3.9.10, Melius Commands
2.1.3 and Simple Voice Chat 2.6.22. Recheck their injection points after upgrades.
FancyMenu and voice compatibility are optional at the mod level; the BotC pack
itself uses them. Mixing other nickname mods requires a separate compatibility check.

## Build and verify

Requires JDK 21. Gradle 9.2.1 is provided through a checksum-pinned wrapper.
FancyMenu is a compile-only dependency from the prepared upstream instance;
its binary is not bundled into this mod.

```powershell
./scripts/build_display_names.ps1
python scripts/check_display_names.py
python scripts/check_localization.py
python extensions/display-names/smoke_test.py --java /path/to/java
```

Alternatively, run `./gradlew build` in this directory. Pass
`-PfancyMenuJar=/absolute/path/to/fancymenu.jar` if the dependency is elsewhere.
The assertion-based Java check covers multiple scripts, normalization and invalid
input without a test framework. The smoke check needs a prepared `server/` with
its EULA accepted. It creates a new offline, loopback-only server under `build/`,
uses two Carpet players, checks real command/selector behavior, duplicate names,
reset and persistence across restarts, and leaves its logs for inspection.
It never changes the existing server/world.

Before release, also exercise two real clients: grimoire hover/actions, empty
seats, nomination/voting, pointing, neighboring/non-neighboring whispers,
name tags, tab list, voice group/HUD/volume labels, live renaming and reconnecting.
The headless smoke check does not validate rendered client layouts or audio.
