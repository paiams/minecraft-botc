# Localization

This fork provides an extensible localization structure for the built-in content
of Minecraft BotC, with Korean as the first added language. See the
[current baseline](README.md#current-baseline) for version information.
It is not Korean-only: shared translation keys and locale files allow additional
languages without duplicating game logic. English and Korean are currently
provided; other translations are not yet included.

See [Contributing](CONTRIBUTING.md) for development and upstream policies, and
[README](README.md#ai-disclosure) for the AI disclosure.

## Adding a language

Add a locale file in
`resources/resourcepack/required/Blood on the Clocktower/assets/minecraft/lang/`
alongside `en_us.json` and `ko_kr.json`, reusing the English
translation keys. Preserve internal IDs, commands, placeholders and formatting
codes. Check key coverage, UI layout and mixed-language multiplayer behavior.
The current localization checker targets English and Korean; additional locales
need equivalent validation rather than assuming that a passing check covers them.
External mod settings and text embedded in artwork have separate limitations
described below.

## Korean sources and style

- Terminology snapshot: TPI `botc-translations` commit `e7cf7fd`.
- Names follow the recorded Korean terminology snapshot; sentences specific to this
  modpack were translated directly from the English source without a translation
  service.
- Descriptions use polite declarative Korean. Storyteller instructions use short
  procedural sentences. Buttons use short noun phrases.
- Internal IDs, commands, translation keys, placeholders, formatting codes, and
  bracketed setup modifiers are never translated.

For the exact Korean terminology, consult `ko_kr.json` and the recorded TPI
translation snapshot. Locale files remain the source of translated display text;
repository documentation is written in English.

## Current scope

For the current baseline, Korean covers every built-in character name and ability, all reminder
tokens, first- and other-night instructions, Jinxes, the three built-in script
selection labels, and the modpack-owned setup, role assignment, phase,
nomination, voting, death, execution, Grimoire, quick-action, settings, timer,
HUD, Home Compass, tutorial, sound subtitles, required-pack descriptions,
credits, main/pause menus, the pinned release changelog, and special-character
flows.

The GitHub wiki is a test reference, not part of the pack, and remains English.
Character flavor text is retained as internal source data because the current baseline never
renders it. Imported script titles, authors, and unknown night hints are shown
verbatim. Third-party Chatbind labels, Simple Voice Chat/EnhancedGroups group
names, and Flan permission-group names remain English because those mods store
shared literal names instead of resolving a per-client locale; changing them
would break mixed Korean/English clients or their command bindings. External
mod and shader settings, optional icon-pack descriptions, and third-party pack
credits remain in their source language.

The stylized script-title PNGs are artwork shared by every client, so the
English lettering embedded in those logos is retained. Script names beside and
under those images use locale keys. Internal values such as character IDs,
voice-chat group IDs, and the `Nobody!` empty-seat sentinel also stay English;
they are command/profile data rather than translated display copy. FancyMenu
maps `Nobody!` to a localized empty-seat label wherever it is rendered. The
`Yambonaut` vote sentinel is a profile name used to render a player-head glyph,
not a visible label, and is likewise retained.

## Updating

1. Work against the current pinned baseline. Evaluate a release upgrade separately
   under the [contribution policy](CONTRIBUTING.md); do not automatically rebase or mix releases.
   When adopting a verified upgrade, update README's Current Baseline and tooling,
   and revalidate the coverage and limitations described here.
2. Compare `en_us.json` in the locale directory above and hardcoded user-facing strings.
3. Compare official Korean terminology against the recorded TPI commit.
4. Translate every new or changed built-in character, reminder, Jinx, and
   modpack-owned UI/message string.
5. Run `python scripts/check_localization.py`.
6. Smoke-test the full setup → night → day → nomination → vote → execution flow
   in every affected language, including a mixed-language multiplayer session.
7. Follow the [packaging instructions](.github/PACKAGING_INSTRUCTIONS.md) and confirm that the exported
   `.mrpack` contains all supported locale files under the included `resources`
   directory.

The checker requires `ko_kr.json` and `en_us.json` to contain the same keys. It
also verifies every built-in night instruction, translated sound subtitle and
pack reference, and rejects hardcoded English in the modpack-owned datapack,
Melius command, and FancyMenu paths.
