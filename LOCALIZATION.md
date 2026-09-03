# Localization

This fork adds Korean localization for the built-in content of Minecraft BotC
1.6.0 (`fc5d8ee`). It is not affiliated with or endorsed by The Pandemonium
Institute, MTS Games, or the upstream modpack maintainers.

The upstream project prohibits AI-assisted contributions. This localization was
created with AI assistance. Do not contact upstream or submit any part of it
without the fork owner's explicit request; upstream maintainer approval would
also be required before a contribution. See `CONTRIBUTING.md`.

## Sources and style

- Terminology snapshot: TPI `botc-translations` commit `e7cf7fd`.
- Names follow current official Korean terminology; sentences specific to this
  modpack were translated directly from the English source without a translation
  service.
- Descriptions use polite declarative Korean. Storyteller instructions use short
  procedural sentences. Buttons use short noun phrases.
- Internal IDs, commands, translation keys, placeholders, formatting codes, and
  bracketed setup modifiers are never translated.

Core terms: Trouble Brewing = 점철되는 혼란, Storyteller = 이야기꾼,
Townsfolk = 주민, Outsider = 외지인, Minion = 하수인, Demon = 악마,
Grimoire = 마도서, nomination = 지목, execution = 처형, vote = 투표,
red herring = 허상, poisoned = 중독, drunk = 취함, dead = 사망,
alive = 생존.

## Current scope

Korean covers every built-in 1.6.0 character name and ability, all reminder
tokens, first- and other-night instructions, Jinxes, the three built-in script
selection labels, and the modpack-owned setup, role assignment, phase,
nomination, voting, death, execution, Grimoire, quick-action, settings, timer,
HUD, Home Compass, tutorial, and special-character flows.

The GitHub wiki is a test reference, not part of the pack, and remains English.
Character flavor text is retained as internal source data because 1.6.0 never
renders it. Imported script titles, authors, and unknown night hints are shown
verbatim. Third-party Chatbind labels and EnhancedGroups group names also remain
English because those mods store shared literal names instead of resolving a
per-client locale; changing them would break mixed Korean/English clients or
their command bindings. External mod settings are owned by their respective mods.
The Home Compass uses one translation component for both item creation and the
dawn cleanup predicate.

## Updating

1. Rebase on the intended upstream release; do not mix release branches.
2. Compare `assets/minecraft/lang/en_us.json` and hardcoded user-facing strings.
3. Compare official Korean terminology against the recorded TPI commit.
4. Translate every new or changed built-in character, reminder, Jinx, and
   modpack-owned UI/message string.
5. Run `python scripts/check_localization.py`.
6. Smoke-test the full setup → night → day → nomination → vote → execution flow
   in both Korean and English, including a mixed-language multiplayer session.
7. Follow `.github/PACKAGING_INSTRUCTIONS.md` and confirm that the exported
   `.mrpack` contains the Korean language file under the included `resources`
   directory.

The checker requires `ko_kr.json` and `en_us.json` to contain the same keys. It
also verifies every built-in night instruction and rejects hardcoded English in
the modpack-owned datapack and FancyMenu paths.
