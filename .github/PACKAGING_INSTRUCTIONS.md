# Packaging the multilingual custom fork

The checklist below was inherited from upstream. Keep the name
`Blood on the Clocktower`, use a fork-specific version, and identify the export
as unofficial in its description instead of presenting it as the official modpack. Include
`README.md`, `LOCALIZATION.md`, `KEYBINDS.md`, `CONTRIBUTING.md`, `LICENSE`
and `COPYRIGHT`, and verify third-party
redistribution conditions before publishing. Package against the currently adopted
baseline listed in [README](../README.md#current-baseline), not an unvalidated
upstream release. After a verified upgrade, update that reference and the actual
setup/dependency pins together; see [CONTRIBUTING.md](../CONTRIBUTING.md).

World cleanup below applies only to a backed-up export copy, never a live world.
Do not export personal player data or logs. The local dedicated-server setup
enables Carpet; the client-export instruction below is not a server instruction.

## Prepare a Personal Instance

1. Clone this repository with Git so the upstream baseline is available for
   comparison. Install the exact upstream pack version listed in
   [Current Baseline](../README.md#current-baseline) in a fresh launcher instance.
2. Close the instance and back it up. Compare the checkout against the baseline
   with `git diff <baseline-commit> -- config resources scripts/loaded_script.json`.
   Apply the fork's changed files to the instance, including any removals. Do not
   replace an existing personal profile wholesale or copy runtime logs and settings.
3. Build the required datapack and resource-pack archives as described below,
   retaining their expected paths. Configure a compatible world and matching server,
   then test the instance before exporting it. This manual route requires familiarity
   with Minecraft datapacks and launcher profiles.

For a local dedicated server, run `./scripts/setup_local_server.ps1` from a Git
checkout in PowerShell with Git and Java 21 installed. It downloads pinned
dependencies and prepares `server/`; review the Minecraft EULA before starting it.
The server is localhost-only and enables Carpet for testing. It applies the
current checkout, not a selected release asset. Stop and back up the server before
rerunning setup; existing server properties and EULA choices are preserved.
Use `-VerifyOnly` to check an existing setup without rebuilding it.

The generated `server/client/BotC-resources-<baseline>.zip` contains resources only, not the full fork
or an importable `.mrpack`. Do not use the dedicated-server directory as a client
export source.

Older setups used the filename `BotC-ko-KR-<baseline>.zip`. Rerun setup with the
server stopped to generate the renamed file; existing copies are not removed.
For a release-matched server, use the release `.mrpack` and a compatible server
installer that preserves `server-overrides`, rather than this development script.

## Export Checklist

- Ensure that a game is not active by opening the Grimoire and clicking Reset Game.
- Verify that `./config/yosbr/chatbinds/binds.json` has all correct default bindings.
- Set FM variable `version` to your desired version.
- Set Custom Window Title in FancyMenu to `Blood on the Clocktower` + `<version>`
- Set FM variable `beta` to `false` if applicable.
- Do `/function ct:dev/package` in-game to automatically disable any active dev features.
- Do `Left CTRL + Left Alt + C` in any menu to disable the FM toolbar.
- Zip any included datapacks.
- Zip any included resource packs.
- Delete the following files and folders from your world file:
    - `/advancements`
    - `/data/Mansion_index`
    - `/data/Mineshaft_index`
    - `/data/Monument_index`
    - `/data/raids`
    - `/data/Stronghold_index`
    - `/data/Temple_index`
    - `/data/Village_index`
    - `/datapacks`
    - `/playerdata`
- Move (or copy) the world from `./saves` to `./`
- In the Modrinth client, disable Carpet mod.
- Set your profile name to `Blood on the Clocktower`.
- Export as an .mrpack with the following settings:

Modpack Name: `Blood on the Clocktower`
Version: `<version>`
Description: `An unofficial fork of Blood on the Clocktower for Minecraft.`

Included Files:

  - `./config/drippyloadingscreen`
  - `./config/enhancedgroups`
  - `./config/fancymenu`
  - `./config/flan`
  - `./config/melius-commands`
  - `./config/spiffyhud`
  - `./config/yosbr`
  - `./fancymenu_data`
  - `./mods`
  - `./resources`
  - `./saves`
  - `./scripts`
  - `./shaderpacks`
  - `./LICENSE`
  - `./COPYRIGHT`
  - `./README.md`
  - `./LOCALIZATION.md`
  - `./KEYBINDS.md`
  - `./CONTRIBUTING.md`
  - If you have added any bindings, also include `./config/chatbinds`

## Share or Install the Export

Import the `.mrpack` into a fresh instance in a compatible launcher and verify
that it works without relying on files from your development profile. Keep the
export for personal use or, after checking redistribution rights, attach it to a
GitHub Release with its fork version and compatible server information.

Users download the release asset and import it locally. Updates are manual;
uploading a file to GitHub does not create a Modrinth project or automatic updates.
GitHub's generated source archives are not substitutes for the `.mrpack` asset.
