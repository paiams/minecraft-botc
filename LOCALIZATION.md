# Localization

This fork adds Korean localization for the Trouble Brewing script on top of
Minecraft BotC 1.6.0 (`fc5d8ee`). It is not affiliated with or endorsed by The
Pandemonium Institute, MTS Games, or the upstream modpack maintainers.

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
red herring = 허상, poisoned = 중독, drunk = 취함.

## Current scope

Korean covers Trouble Brewing's 22 character names and abilities, its reminder
tokens and night instructions, and the shared setup, phase, nomination, voting,
death, execution, Grimoire, and tutorial flow needed to run that script.

Characters outside Trouble Brewing, Travellers, Fabled, Lorics, Jinxes, external
mod settings, third-party saved Chatbind labels, flavor text, and the GitHub wiki
remain English. Imported custom scripts retain their embedded English night hints
when they do not provide a known localization key. The Home Compass display name
also remains English because the v1.6.0 datapack uses that literal name as an
internal item predicate; localizing it safely requires a separate item-data change.

## Updating

1. Rebase on the intended upstream release; do not mix release branches.
2. Compare `assets/minecraft/lang/en_us.json` and hardcoded user-facing strings.
3. Compare official Korean terminology against the recorded TPI commit.
4. Translate only new or changed Trouble Brewing/shared-flow text.
5. Run `python scripts/check_localization.py`.
6. Smoke-test the full setup → night → day → nomination → vote → execution flow
   in both Korean and English, including a mixed-language multiplayer session.

The checker permits `ko_kr.json` to be a subset of `en_us.json`; omitted keys use
Minecraft's normal English fallback. New localized references and all required
Trouble Brewing keys must still exist in both files.
