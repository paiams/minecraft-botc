![Blood on the Clocktower logo](config/fancymenu/assets/menu/loading_logo.png)

Play Steven Medway's Blood on the Clocktower in Minecraft—a social deduction game where death is not the end.

This is an unofficial fork of [Sybillian's Minecraft modpack](https://github.com/Sybillian/minecraft-botc), maintained with a focus on multilingual play, reliability, and ease of use. It is not affiliated with or endorsed by The Pandemonium Institute, MTS Games, or the upstream maintainers.

## Languages

English and Korean are included. Korean is the first added translation, but the project is not limited to Korean: shared translation keys and locale files support adding further languages.

Localization covers the pack's characters, abilities, reminders, night instructions, and in-game interfaces. Some third-party settings and text embedded in artwork remain in their original language. See [Localization](LOCALIZATION.md) for coverage and guidance on adding a language.

Player display names also support multiple writing systems through the included
[BotC Display Names extension](extensions/display-names/README.md). Install the
extension on both server and clients; account names remain the internal identifiers.

## Getting Started

### Import a release pack

When available, download the `.mrpack` asset from this repository's
[GitHub Releases](https://github.com/paiams/minecraft-botc/releases) and import it
as a new instance in the Modrinth App or another `.mrpack`-compatible launcher.
If there is no `.mrpack` asset, use the source-build route below; GitHub's automatic
source ZIP is not an installable modpack.

These files are imported locally, not installed through an official Modrinth
listing for this fork. Updates are manual: import the new pack separately and
back up saves and personal settings before migrating them. A `.mrpack` is a pack
installation, not an in-place patch for an existing instance.

### Build your own pack

Use the [source preparation and export guide](.github/PACKAGING_INSTRUCTIONS.md)
to assemble a personal instance and export it. This is a manual workflow, not a
one-command client installer.

### Set up a server

For daily development, double-click `sync-dev.cmd` to update the existing `server/`
and `%APPDATA%/ModrinthApp/profiles/Blood on the Clocktower` together. It waits
for Minecraft and local Fabric servers to close normally (use `stop` in the server
console), builds the shared mod, and applies the checkout's changes, including
uncommitted edits and new non-ignored content files. It rebuilds the datapack ZIP
on both targets and the server's resource ZIP, backs up changed files under
`.dev-sync-backups/`, verifies copies, and restores applied files if copying fails.
It also builds the sibling `minecraft-botc-broadcast` checkout and updates its
server-only JAR when the built file differs, after its build and self-tests pass.
Pregame bag, seating and role UI changes are included, along with OBS event hooks
in the datapack source; no manual server-only hook patch is needed.
Worlds, credentials, and unrelated personal settings are preserved. Restart both
runtimes afterward. This updates development content, not upstream dependencies.
Run `powershell -NoProfile -File scripts/sync_dev.ps1 -CheckOnly` to validate paths
without building or changing runtime files; use `-ServerDirectory` and
`-ClientDirectory` to override the destinations.

For a server matching a release, install the same `.mrpack` using a compatible
server installer that applies `server-overrides`. Follow the release's server
notes and review the Minecraft EULA before starting it.

For local development on Windows, use the
[local server setup script](scripts/setup_local_server.ps1) from a Git checkout
with JDK 21 installed (including the Java compiler for the display-name extension):

```powershell
./scripts/setup_local_server.ps1
```

It prepares `server/` from the current checkout, binds to `localhost:25565`, and
enables Carpet for testing. After reviewing and accepting the EULA in
`server/eula.txt`, run `start-local-server.cmd`. Stop and back up an existing
server before rebuilding. This is not a public-server installer and does not
export a client `.mrpack`.

You will need a world configured for this modpack and compatible client and server
installations. See [keyboard shortcuts](KEYBINDS.md) for play controls and the
upstream [client](https://github.com/Sybillian/minecraft-botc/wiki/Installation:-Client)
and [server](https://github.com/Sybillian/minecraft-botc/wiki/Installation:-Server)
guides for background setup information.

The [original modpack on Modrinth](https://modrinth.com/modpack/blood-on-the-clocktower) is the upstream release, not a download of this fork. Upstream guides may describe a newer version; use the baseline below when checking compatibility.

## Current Baseline

- Upstream modpack: **1.6.0**, commit `fc5d8ee`.
- Runtime: Minecraft **1.21.11** / Fabric Loader **0.19.4**.

Upstream updates are evaluated selectively, with stability and localization taking priority over release parity. Individual fixes may be backported without changing the baseline.

## Development

`main` contains the stable version. Changes and upstream upgrades are tested on separate branches before merging. See [Contributing](CONTRIBUTING.md) for the development and update policy. Please report fork-specific issues in this repository.

## Credits and License

Blood on the Clocktower was created by Steven Medway, and the original Minecraft modpack by Sybillian.

Pixel-art character icons were created by members of the upstream Discord community. Playtest Art icons come from [tomozbot/botc-icons](https://github.com/tomozbot/botc-icons/); upstream states that they are used with permission. Other project-specific game assets were created by Sybillian. Game rules belong to The Pandemonium Institute and are not included in this modpack.

This fork retains the [GNU GPLv3 license](LICENSE). Copyright for paiams's fork modifications and additions is recorded in [COPYRIGHT](COPYRIGHT), separately from the original work. Third-party mods, artwork, and trademarks may have separate terms.

## AI Disclosure

AI tools have been used for this fork's translations, code changes, and documentation. The upstream creator opposes AI use and AI-assisted contributions; upstream's AI-free declaration does not apply to this fork. The original position is preserved in the [historical README](https://github.com/Sybillian/minecraft-botc/blob/fc5d8ee/README.md) and [contribution policy](https://github.com/Sybillian/minecraft-botc/blob/fc5d8ee/CONTRIBUTING.md).
