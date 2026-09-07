# Working on This Fork

This is a multilingual custom fork of Minecraft BotC. See the [current baseline](README.md#current-baseline) for version information. Its goals are extensible localization, starting with Korean, and improved gameplay usability—not full upstream feature parity or preparation for upstream pull requests.

## Changes and Bug Reports

- Keep `main` as the verified stable branch. Develop translations, gameplay fixes, compatibility changes, and usability improvements on short-lived topic branches, then merge after validation.
- Stabilize the current baseline first. Evaluate upstream updates selectively; changing the baseline requires a separate decision, not automatic release tracking.
- Add languages through locale files sharing existing translation keys. Preserve internal IDs, commands, and placeholders; do not duplicate game logic per language. Current translation checks cover English and Korean, so additional locales need their own key-coverage and display validation.
- Write repository documentation in English. Keep localized game content in its appropriate locale files.
- Include the version, reproduction steps, expected behavior, and actual behavior in bug reports. Remove personal information from logs. Investigate fork-specific issues here first.
- Keep unrelated changes in separate commits. Do not overwrite running client or server files; back up target files before deployment.
- Do not commit worlds, logs, account information, built runtime binaries, or personal settings.

## Upstream Updates

Stability and localization take priority over release parity. The fork is not permanently locked to its current baseline, but may skip upstream releases.

1. Review the candidate changes and their dependencies. Backport important fixes only when compatible with the current baseline, recording their upstream source.
2. For a release upgrade, use a separate local integration branch and preserve the existing stable version. Do not rewrite published history or modify live runtime files as part of evaluation.
3. Keep translation data, localization infrastructure, gameplay fixes, and mod compatibility changes in focused commits. Remove redundant workarounds once an upstream replacement is verified.
4. Run the relevant static checks and in-game regression tests below, including mixed-language play. Adopt the new baseline only after validation; otherwise defer or skip it.
5. On adoption, update README's Current Baseline and the actual dependency pins and setup/verification scripts together. Recheck translation coverage and packaging instructions for behavioral changes; do not duplicate version declarations across documents.

Use `upgrade/<upstream-version>` for upgrade trials and `fix/<topic>` for focused
fixes. Mark verified stable snapshots with immutable `v<baseline>-fork.<revision>`
tags. Preserve upstream source and
license evidence when adopting a new baseline.

## Verification

Run the checks relevant to your changes from the repository root.

```powershell
python scripts/check_localization.py
python scripts/check_localization.py --self-test
python scripts/check_ui_empty_state.py
python scripts/check_pyre_target.py
git diff --check
```

Static checks do not replace in-game testing. For gameplay changes, test setup → night → day → nomination → vote → execution, as well as death and revival, and record anything still unverified. Test translations in English, Korean, any newly added language, and mixed-language sessions.

## AI and Upstream

This fork uses AI tools. AI-assisted output still requires human review and behavioral verification. Do not present upstream's AI-free declaration as a statement about this fork.

The upstream creator's opposition to AI and contribution policy are preserved in the [original CONTRIBUTING.md](https://github.com/Sybillian/minecraft-botc/blob/fc5d8ee/CONTRIBUTING.md). This document neither changes that policy nor authorizes contributions on upstream's behalf.

This fork does not submit AI-assisted changes upstream. Direct fork-specific
issues and contributions here, and respect the upstream project's contribution policy.

Preserve attribution and license notices, and separately check redistribution conditions for third-party mods and assets.
