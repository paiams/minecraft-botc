#!/usr/bin/env python3
"""Static checks for the complete Korean localization of the Clocktower pack.

The language file is JSON with comments (JSONC), while datapack and FancyMenu
files contain a mixture of JSON-like snippets and plain text.  This checker is
deliberately dependency-free so it can run before Minecraft is launched and in
an upstream checkout without installing a toolchain.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterator, Mapping, Sequence


# UI used while setting up and running a game.
CORE_UI_KEYS: tuple[str, ...] = (
    "clocktower.header.town",
    "clocktower.header.outsiders",
    "clocktower.header.minions",
    "clocktower.header.demons",
    "clocktower.ui.demon_bluffs",
    "clocktower.ui.first_night_order",
    "clocktower.ui.other_nights_order",
    "clocktower.button.game_actions.label",
    "clocktower.button.special_actions.label",
    "clocktower.button.tp_church.label",
    "clocktower.button.tp_church.hint_disabled",
    "clocktower.button.tp_seats.label",
    "clocktower.button.tp_homes.label",
    "clocktower.button.tp_homes.hint",
    "clocktower.button.reset_game.label",
    "clocktower.button.reset_game.label_alt",
    "clocktower.button.reset_game.hint",
    "clocktower.button.close_menu.label",
    "clocktower.item.skull.name",
    "clocktower.item.notebook.name",
    "clocktower.item.grimoire.name",
    "clocktower.item.script.name",
    "clocktower.item.start_vote.name",
    "clocktower.prefix.notification",
    "clocktower.prefix.error",
    "clocktower.prefix.the",
    "clocktower.error.too_many_players",
    "clocktower.error.not_enough_players",
    "clocktower.error.not_night",
    "clocktower.error.not_storyteller",
    "clocktower.error.game_not_active",
    "clocktower.error.game_active",
    "clocktower.error.whisper_not_neighbor",
    "clocktower.error.whisper_self",
    "clocktower.error.whisper_wrong_phase",
    "clocktower.command.spectator",
    "clocktower.command.msg",
    "clocktower.command.msg.you",
    "clocktower.command.msg.st_visible",
    "clocktower.notice.ferryman",
    "clocktower.bossbar.day_time",
    "clocktower.bossbar.votes",
    "clocktower.ui.start_night_1",
    "clocktower.ui.home_of",
    "clocktower.ui.you_are",
    "clocktower.item.home_compass",
    "clocktower.vote.yes",
    "clocktower.vote.no",
    "clocktower.vote.close",
    "clocktower.vote.your",
    "clocktower.vote.eyes",
    "clocktower.notice.setup.bag_created",
    "clocktower.notice.nomination",
    "clocktower.notice.voting.changed",
    "clocktower.notice.voting.current",
    "clocktower.notice.voting.cast",
    "clocktower.notice.voting_on",
    "clocktower.notice.vote_started",
    "clocktower.notice.vote_started_blind",
    "clocktower.notice.votes_received",
    "clocktower.notice.players_voted",
    "clocktower.notice.player_died",
    "clocktower.notice.player_executed",
    "clocktower.notice.player_marked_execution",
    "clocktower.notice.no_execution",
    "clocktower.notice.player_revived",
    "clocktower.notice.phase.dawn",
    "clocktower.notice.phase.dusk",
    "clocktower.notice.phase.dusk_nominations",
    "clocktower.notice.phase.night",
    "clocktower.notice.player_not_in_house",
    "clocktower.notice.reveal_ability_hint",
    "clocktower.notice.welcome_pronouns",
    "clocktower.notice.game_active_mute",
    "clocktower.notice.spectator_joined",
    "clocktower.notice.chat_request_storyteller",
    "clocktower.notice.chat_request_you",
    "clocktower.voicechat.status_everyone",
    "clocktower.voicechat.status_storyteller",
    "clocktower.voicechat.status_local",
    "clocktower.voicechat.status",
    "clocktower.voicechat.listening",
    "clocktower.voicechat.listening_night",
    "clocktower.voicechat.listening_local",
    "clocktower.voicechat.night_chat",
    "clocktower.voicechat.joined",
    "clocktower.voicechat.exited",
    "clocktower.voicechat.joined_location",
    "clocktower.notice.demon_warning",
    *(f"clocktower.voicechat.location.{location}" for location in (
        "beet_field", "wheat_field", "church_of_miku", "graveyard",
        "greenhouse", "inn", "bakery", "storyteller_den", "red_house",
        "orange_house", "yellow_house", "lime_house", "green_house",
        "mint_house", "cyan_house", "blue_house", "navy_house",
        "purple_house", "pink_house", "lavender_house", "white_house",
        "gray_house", "black_house",
    )),
    "clocktower.role.alignment.townsfolk",
    "clocktower.role.alignment.outsider",
    "clocktower.role.alignment.minion",
    "clocktower.role.alignment.demon",
    "clocktower.role.alignment.neutral",
    "clocktower.role.alignment.storyteller",
    "clocktower.role.hidden",
    "clocktower.item.setup_bag.name",
    "clocktower.item.voting_prefix",
    "clocktower.item.right_click",
    # Loading-screen tips are the only tutorial/help copy in this pack.
    *(f"clocktower.hint_{number}.{part}" for number in range(1, 13) for part in ("title", "header", "body")),
    "clocktower.script.trouble_brewing.name",
)

CORE_FANCYMENU_KEYS: tuple[str, ...] = (
    "clocktower.ui.chat.start_night.description",
    "clocktower.ui.chat.timer",
    "clocktower.ui.chat.request_storyteller.description",
    "clocktower.ui.chat.advance_phase",
    "clocktower.ui.chat.mark",
    "clocktower.ui.chat.mark_prefix",
    "clocktower.ui.chat.mark_suffix",
    "clocktower.ui.chat.clear_mark",
    "clocktower.ui.chat.clear_mark.description",
    "clocktower.ui.chat.quick_actions",
    "clocktower.ui.chat.quick_actions.description",
    "clocktower.ui.bag.import",
    "clocktower.ui.bag.import.instructions_intro",
    "clocktower.ui.bag.import.instructions_format",
    "clocktower.ui.bag.back",
    "clocktower.ui.bag.import_from_file.description",
    "clocktower.ui.bag.reminders.title",
    "clocktower.ui.bag.reminders.no_direct",
    "clocktower.ui.bag.reminders.setup_counts",
    "clocktower.ui.bag.count_townsfolk",
    "clocktower.ui.bag.count_outsiders",
    "clocktower.ui.bag.count_minions",
    "clocktower.ui.bag.count_demons",
    "clocktower.ui.bag.use",
    "clocktower.ui.bag.use_hint",
    "clocktower.ui.bag.change_script",
    "clocktower.ui.bag.setup_modifier_warning",
    "clocktower.ui.reset.warning_intro",
    "clocktower.ui.reset.warning_data",
    "clocktower.ui.reset.warning_condition",
    "clocktower.ui.reset.warning_announce",
    "clocktower.ui.reset.confirm_question",
    "clocktower.ui.reset.yes",
    "clocktower.ui.reset.no",
    "clocktower.ui.execute.select_for_pyre",
    "clocktower.ui.execute.select_for_execution",
    "clocktower.ui.execute.cancel",
    "clocktower.ui.grimoire.teleport_prefix",
    "clocktower.ui.grimoire.teleport_to_pyre",
    "clocktower.ui.grimoire.light_pyre",
    "clocktower.ui.grimoire.pyre",
    "clocktower.ui.grimoire.execute_prefix",
    "clocktower.ui.grimoire.execute_suffix",
    "clocktower.ui.grimoire.execute",
    "clocktower.ui.grimoire.change_prefix",
    "clocktower.ui.grimoire.change_suffix",
    "clocktower.ui.grimoire.change_character",
    "clocktower.ui.grimoire.living_players",
    "clocktower.ui.grimoire.ghost_votes",
    "clocktower.ui.grimoire.current_day",
    "clocktower.ui.grimoire.toggle_life",
    "clocktower.ui.grimoire.add_reminder",
    "clocktower.ui.grimoire.clear_bluff",
    "clocktower.ui.grimoire.bluffs",
    "clocktower.ui.view_script",
    "clocktower.ui.view_night_order",
    "clocktower.ui.close",
    "clocktower.ui.first_night_order_title",
    "clocktower.ui.other_nights_order_title",
    "clocktower.ui.view_travellers",
    "clocktower.ui.view_jinxes",
    "clocktower.ui.script.every_night_except_first",
    "clocktower.ui.script.created_by",
    "clocktower.ui.script.composition_prefix",
    "clocktower.ui.script.composition_suffix",
    "clocktower.ui.script.composition_townsfolk",
    "clocktower.ui.script.composition_outsider",
    "clocktower.ui.script.composition_minion",
    "clocktower.ui.script.composition_demon",
    "clocktower.ui.script.composition_note",
    "clocktower.ui.script.npcs",
    "clocktower.ui.quick_actions.visibility_description",
    "clocktower.ui.quick_actions.gamemode_prefix",
    "clocktower.ui.quick_actions.teleport",
    "clocktower.ui.quick_actions.execute",
    "clocktower.ui.quick_actions.teleport_house",
    "clocktower.ui.quick_actions.special_abilities",
    "clocktower.ui.quick_actions.teleport_house_question",
    "clocktower.ui.quick_actions.announce",
    "clocktower.ui.quick_actions.nominate",
    "clocktower.ui.nomination.nominator_prompt",
    "clocktower.ui.nomination.nominee_prompt",
    "clocktower.ui.settings.player_options",
    "clocktower.ui.settings.demon_sounds.description",
    "clocktower.ui.settings.demon_sounds.label",
    "clocktower.ui.settings.storyteller_options",
    "clocktower.ui.settings.timer_ends_day.description",
    "clocktower.ui.settings.timer_ends_day.label",
    "clocktower.ui.settings.speed_boost.prefix",
    "clocktower.ui.timer.set",
    "clocktower.ui.timer.description",
    "clocktower.ui.timer.cancel",
    "clocktower.ui.timer.pause_nominations.prefix",
    "clocktower.ui.tutorial.storytelling_guide",
    "clocktower.ui.tutorial.index",
    "clocktower.ui.tutorial.bag",
    "clocktower.ui.tutorial.grimoire",
    "clocktower.ui.tutorial.nominations",
    "clocktower.ui.tutorial.executions",
    "clocktower.ui.tutorial.other",
    "clocktower.ui.role_toggler.view_travellers",
    "clocktower.ui.role_toggler.close",
    "clocktower.ui.role_toggler.clear_character",
    "clocktower.ui.actions",
    "clocktower.ui.hud.day",
    "clocktower.ui.hud.night",
    "clocktower.ui.hud.error",
    "clocktower.ui.hud.since",
    "clocktower.notice.request_chat.on",
    "clocktower.notice.request_chat.off",
    "clocktower.notice.hand.raised",
    "clocktower.notice.hand.lowered",
    "clocktower.notice.teleport.all_players_home",
    "clocktower.notice.teleport.mysterious_home",
    "clocktower.notice.teleport.minions_demons_church",
    "clocktower.notice.teleport.mysterious_church",
    "clocktower.tutorial.welcome",
    "clocktower.command.storyteller_add",
    "clocktower.tutorial.op_suffix",
    "clocktower.tutorial.storyteller_suffix",
    "clocktower.tutorial.docs_prefix",
    "clocktower.tutorial.docs_link",
    "clocktower.tutorial.docs_suffix",
    "clocktower.item.death_token.name",
    "clocktower.item.death_token.lore.cannot_nominate",
    "clocktower.item.death_token.lore.no_ability",
    "clocktower.item.death_token.lore.ghost_vote",
    "clocktower.item.death_token.lore.ghost_vote_more",
    "clocktower.item.death_token.lore.active",
)

# In future commits first/other night text can be added to en_us.  The checker
# then automatically requires its Korean counterpart through the shared key
# subset/format pass; it does not invent fallback keys that are not in English.


class JsoncError(ValueError):
    """Raised when comment removal or JSON parsing fails."""


@dataclass(frozen=True)
class ParsedJson:
    data: dict[str, object]
    duplicate_keys: tuple[str, ...] = ()


def strip_jsonc_comments(source: str) -> str:
    """Return JSON text with // and /* */ comments removed outside strings.

    Replacing comment characters with spaces (while retaining line endings)
    keeps JSONDecodeError line/column information useful and, importantly,
    leaves URLs and slash characters inside quoted values untouched.
    """

    output: list[str] = []
    index = 0
    length = len(source)
    in_string = False
    escaped = False

    while index < length:
        char = source[index]
        if in_string:
            output.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            index += 1
            continue

        if char == '"':
            in_string = True
            output.append(char)
            index += 1
            continue

        if char == "/" and index + 1 < length and source[index + 1] == "/":
            # Preserve CR/LF so diagnostics retain their original line number.
            output.extend((" ", " "))
            index += 2
            while index < length and source[index] not in "\r\n":
                output.append(" ")
                index += 1
            continue

        if char == "/" and index + 1 < length and source[index + 1] == "*":
            output.extend((" ", " "))
            index += 2
            closed = False
            while index < length:
                if source[index] == "*" and index + 1 < length and source[index + 1] == "/":
                    output.extend((" ", " "))
                    index += 2
                    closed = True
                    break
                # Keep line endings; replace all other comment characters.
                if source[index] in "\r\n":
                    output.append(source[index])
                else:
                    output.append(" ")
                index += 1
            if not closed:
                raise JsoncError("unterminated /* block comment")
            continue

        output.append(char)
        index += 1

    if in_string:
        # Let json.loads provide its usual position for malformed strings.
        return "".join(output)
    return "".join(output)


def parse_jsonc(source: str, *, filename: str = "<string>") -> ParsedJson:
    """Parse JSONC and retain duplicate-key diagnostics via object_pairs_hook."""

    duplicates: list[str] = []

    def object_pairs_hook(pairs: list[tuple[str, object]]) -> dict[str, object]:
        result: dict[str, object] = {}
        for key, value in pairs:
            if key in result:
                duplicates.append(key)
            result[key] = value
        return result

    try:
        parsed = json.loads(
            strip_jsonc_comments(source),
            object_pairs_hook=object_pairs_hook,
        )
    except JsoncError:
        raise
    except json.JSONDecodeError as error:
        raise JsoncError(
            f"{filename}:{error.lineno}:{error.colno}: {error.msg}"
        ) from error
    if not isinstance(parsed, dict):
        raise JsoncError(f"{filename}: top-level value must be an object")
    return ParsedJson(parsed, tuple(dict.fromkeys(duplicates)))


def read_jsonc(path: Path) -> ParsedJson:
    return parse_jsonc(path.read_text(encoding="utf-8-sig"), filename=str(path))


PRINTF_RE = re.compile(
    r"%(?:\d+\$)?[-+# 0,(<]*\d*(?:\.\d+)?[a-zA-Z%]"
)
SECTION_RE = re.compile(r"§.", re.DOTALL)
EMPTY_TRANSLATION_ALLOWED = frozenset({"clocktower.prefix.the"})


def format_tokens(value: str) -> dict[str, object]:
    """Extract user-visible formatting tokens that translations must retain."""

    # FancyMenu uses %n% for a line break.  It is not currently present in the
    # language file, but treating it explicitly makes this checker reusable.
    fm_breaks = value.count("%n%")
    without_fm_breaks = value.replace("%n%", "")
    return {
        "printf": Counter(PRINTF_RE.findall(without_fm_breaks)),
        "section": Counter(SECTION_RE.findall(value)),
        "newlines": value.count("\n"),
        "fm_breaks": fm_breaks,
    }


def iter_files(root: Path, directory: Path, suffixes: Sequence[str]) -> Iterator[Path]:
    if not directory.is_dir():
        return
    for path in sorted(directory.rglob("*")):
        if path.is_file() and path.suffix.lower() in suffixes:
            yield path


LOCAL_KEY_RE = re.compile(
    r'"placeholder"\s*:\s*"local"\s*,\s*'
    r'"values"\s*:\s*\{\s*"key"\s*:\s*"([^"\r\n]+)"'
)
TRANSLATE_KEY_RE = re.compile(
    r'(?<![\w.])(?:"translate"|translate)\s*:\s*'
    r'["\'](clocktower\.[A-Za-z0-9_.-]+)["\']'
)


@dataclass(frozen=True)
class KeyReference:
    key: str
    path: Path
    line: int


def local_key_references(directory: Path) -> Iterator[KeyReference]:
    for path in iter_files(directory.parent.parent, directory, (".txt", ".json", ".jsonc", ".properties")):
        try:
            lines = path.read_text(encoding="utf-8-sig").splitlines()
        except UnicodeDecodeError:
            continue
        for line_number, line in enumerate(lines, 1):
            for match in LOCAL_KEY_RE.finditer(line):
                key = match.group(1)
                # Dynamic keys contain a nested placeholder (e.g.
                # clocktower.role.{nbt_data_get_server...}); they resolve at
                # runtime and cannot be checked against a static language map.
                if "{" not in key and "}" not in key:
                    yield KeyReference(key, path, line_number)


def datapack_translate_references(directory: Path) -> Iterator[KeyReference]:
    for path in iter_files(directory.parent.parent.parent.parent, directory, (".mcfunction", ".json", ".jsonc")):
        try:
            lines = path.read_text(encoding="utf-8-sig").splitlines()
        except UnicodeDecodeError:
            continue
        for line_number, line in enumerate(lines, 1):
            if line.lstrip().startswith("#"):
                continue
            for match in TRANSLATE_KEY_RE.finditer(line):
                yield KeyReference(match.group(1), path, line_number)


FM_VISIBLE_FIELDS = frozenset({"label", "description", "hoverlabel", "title", "text", "source"})
FIELD_RE = re.compile(r"^\s*(label|description|hoverlabel|title|text|source)\s*=\s*(.*)$")
TEXT_FIELD_RE = re.compile(r'(?<![\w])"?text"?\s*:\s*"((?:\\.|[^"\\])*)"')
DIRECT_TELLRAW_RE = re.compile(r'\btellraw\s+\S+\s+"((?:\\.|[^"\\])*)"\s*$')
DIRECT_TITLE_RE = re.compile(r"\btitle\b[^\n]*?\btitle\s+\"([^\"]+)\"")
WORD_RE = re.compile(r"\b[A-Za-z]{2,}\b")


@dataclass(frozen=True)
class HardcodedText:
    path: Path
    line: int
    text: str


def _remove_braced_placeholders(value: str) -> str:
    """Remove nested FancyMenu placeholder objects from a visible value."""

    result: list[str] = []
    depth = 0
    in_string = False
    escaped = False
    for char in value:
        if depth:
            if in_string:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == '"':
                    in_string = False
            elif char == '"':
                in_string = True
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
            continue
        if char == "{":
            depth = 1
            in_string = False
        else:
            result.append(char)
    return "".join(result)


def _looks_like_user_english(value: str) -> bool:
    cleaned = _remove_braced_placeholders(value)
    # FancyMenu uses this invisible sentinel to measure two bundled fonts.
    cleaned = cleaned.replace("this is a custom font", " ")
    cleaned = re.sub(r"https?://\S+", " ", cleaned)
    cleaned = re.sub(r"\$\([^)]*\)", " ", cleaned)
    cleaned = re.sub(r"%[^%\n]*%", " ", cleaned)
    cleaned = re.sub(r"\[[^\]\n]*\]", " ", cleaned)
    cleaned = re.sub(r"(?:^|\s)/[A-Za-z0-9_./<>-]+", " ", cleaned)
    return bool(WORD_RE.search(cleaned))


def find_hardcoded_fancymenu(path: Path) -> Iterator[HardcodedText]:
    try:
        lines = path.read_text(encoding="utf-8-sig").splitlines()
    except UnicodeDecodeError:
        return
    for line_number, line in enumerate(lines, 1):
        if line.lstrip().startswith("#"):
            continue
        match = FIELD_RE.match(line)
        if not match or match.group(1) not in FM_VISIBLE_FIELDS:
            continue
        value = match.group(2).strip()
        # ``source`` is also FancyMenu's image/font path field.  Those paths
        # are not user-facing copy and must not fail a translation check when
        # a new texture is added.
        if match.group(1) == "source" and (
            value.startswith("[source:")
            or "textures/" in value
            or re.search(r"\.(?:png|jpg|jpeg|gif|webp)(?:\W|$)", value, re.I)
        ):
            continue
        if value and _looks_like_user_english(value):
            yield HardcodedText(path, line_number, value)


def find_hardcoded_datapack(path: Path) -> Iterator[HardcodedText]:
    try:
        lines = path.read_text(encoding="utf-8-sig").splitlines()
    except UnicodeDecodeError:
        return
    for line_number, line in enumerate(lines, 1):
        if line.lstrip().startswith("#"):
            continue
        found = False
        for match in TEXT_FIELD_RE.finditer(line):
            raw = match.group(1)
            try:
                value = json.loads(f'"{raw}"')
            except json.JSONDecodeError:
                value = raw
            if _looks_like_user_english(value):
                found = True
                yield HardcodedText(path, line_number, value)
        if found:
            continue
        match = DIRECT_TELLRAW_RE.search(line) or DIRECT_TITLE_RE.search(line)
        if match and _looks_like_user_english(match.group(1)):
            yield HardcodedText(path, line_number, match.group(1))


def _relative(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


@dataclass
class Report:
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    def error(self, message: str) -> None:
        self.errors.append(message)

    def warning(self, message: str) -> None:
        self.warnings.append(message)


def _required_keys() -> tuple[str, ...]:
    # Preserve declaration order while removing any accidental duplicate.
    return tuple(dict.fromkeys((*CORE_UI_KEYS, *CORE_FANCYMENU_KEYS)))


def check_language_files(en_path: Path, ko_path: Path, report: Report) -> tuple[Mapping[str, object], Mapping[str, object]]:
    try:
        en = read_jsonc(en_path)
    except (OSError, JsoncError) as error:
        report.error(f"English language file: {error}")
        return {}, {}
    for key in en.duplicate_keys:
        report.error(f"{_relative(en_path, en_path.parents[5] if len(en_path.parents) > 5 else en_path.parent)}: duplicate key {key!r}")

    try:
        ko = read_jsonc(ko_path)
    except (OSError, JsoncError) as error:
        report.error(f"Korean language file: {error}")
        return en.data, {}
    for key in ko.duplicate_keys:
        report.error(f"{ko_path}: duplicate key {key!r}")

    unknown = sorted(set(ko.data) - set(en.data))
    for key in unknown:
        report.error(f"ko_kr key is not present in en_us (fallback key typo?): {key}")

    for key in sorted(set(en.data) - set(ko.data)):
        report.error(f"ko_kr missing English fallback key: {key}")

    for key, ko_value in ko.data.items():
        if key not in en.data:
            continue
        en_value = en.data[key]
        if not isinstance(en_value, str) or not isinstance(ko_value, str):
            report.error(f"{key}: language values must both be strings")
            continue
        if not ko_value.strip() and en_value.strip() and key not in EMPTY_TRANSLATION_ALLOWED:
            report.error(f"{key}: Korean translation is empty")
        expected = format_tokens(en_value)
        actual = format_tokens(ko_value)
        if expected != actual:
            report.error(
                f"{key}: formatting tokens changed "
                f"(en={expected}, ko={actual})"
            )

    required = _required_keys()
    for key in required:
        if key not in en.data:
            report.error(f"en_us missing required UI key: {key}")
        if (
            key not in ko.data
            or not isinstance(ko.data.get(key), str)
            or (not str(ko.data.get(key)).strip() and key not in EMPTY_TRANSLATION_ALLOWED)
        ):
            report.error(f"ko_kr missing required UI key: {key}")
    return en.data, ko.data


NIGHT_KEY_RE = re.compile(
    r'"(?P<kind>first_night_key|other_night_key)"\s*:\s*'
    r'"(?P<key>clocktower\.role\.(?P<role>[a-z0-9_]+)\.(?:first_night|other_night))"'
)
CHARACTER_START_RE = re.compile(r'^\t\t"(?P<role>[a-z0-9_]+)"\s*:\s*\{')
CHARACTER_FIELD_RE = re.compile(
    r'^\s*"(?P<field>name|ability|first|other|first_night_key|other_night_key)"\s*:\s*'
    r'"(?P<value>(?:\\.|[^"\\])*)"'
)
REMINDER_ID_RE = re.compile(r'(?:^|[,{])text:([a-z0-9_]+)(?=[,}])')
NIGHT_KEY_LINE_RE = re.compile(r'"(?:first|other)_night_key"\s*:')


def character_fields(source: str) -> dict[str, dict[str, str]]:
    """Extract localizable fields from character_data.mcfunction."""

    characters: dict[str, dict[str, str]] = {}
    current_role: str | None = None
    for line in source.splitlines():
        role_match = CHARACTER_START_RE.match(line)
        if role_match:
            current_role = role_match.group("role")
            characters[current_role] = {}
            continue
        if current_role is None:
            continue
        if line.startswith("\t\t}"):
            current_role = None
            continue
        field_match = CHARACTER_FIELD_RE.match(line)
        if not field_match:
            continue
        raw_value = field_match.group("value")
        try:
            value = json.loads(f'"{raw_value}"')
        except json.JSONDecodeError:
            value = raw_value
        characters[current_role][field_match.group("field")] = value
    return characters


def check_character_keys(root: Path, en_keys: Mapping[str, object], ko_keys: Mapping[str, object], report: Report) -> None:
    """Require localized names, abilities, reminders, and night hints."""

    path = root / "resources" / "datapack" / "required" / "ct" / "data" / "ct" / "function" / "data" / "character_data.mcfunction"
    if not path.is_file():
        return
    try:
        source = path.read_text(encoding="utf-8-sig")
    except (OSError, UnicodeDecodeError) as error:
        report.error(f"cannot read character data for night-key check: {error}")
        return
    lines = source.splitlines()
    for index, line in enumerate(lines):
        if NIGHT_KEY_LINE_RE.search(line) and (index == 0 or not lines[index - 1].rstrip().endswith(",\\")):
            report.error(
                f"{_relative(path, root)}:{index + 1}: night locale key lacks a preceding field separator"
            )
    for role, fields in sorted(character_fields(source).items()):
        for source_field, suffix in (("name", "name"), ("ability", "desc")):
            if source_field not in fields:
                continue
            expected_key = f"clocktower.role.{role}.{suffix}"
            if expected_key not in en_keys:
                report.error(f"en_us missing built-in character key: {expected_key}")
            if (
                expected_key not in ko_keys
                or not isinstance(ko_keys.get(expected_key), str)
                or not str(ko_keys.get(expected_key)).strip()
            ):
                report.error(f"ko_kr missing built-in character key: {expected_key}")
        for source_field, key_field, suffix in (
            ("first", "first_night_key", "first_night"),
            ("other", "other_night_key", "other_night"),
        ):
            if source_field not in fields:
                continue
            expected_key = f"clocktower.role.{role}.{suffix}"
            if fields.get(key_field) != expected_key:
                report.error(
                    f"character_data {role}.{source_field} missing locale field "
                    f"{key_field}={expected_key!r}"
                )
            if en_keys.get(expected_key) != fields[source_field]:
                report.error(
                    f"en_us {expected_key} must preserve character_data {source_field} fallback"
                )
            if (
                expected_key not in ko_keys
                or not isinstance(ko_keys.get(expected_key), str)
                or not str(ko_keys.get(expected_key)).strip()
            ):
                report.error(f"ko_kr missing built-in night hint key: {expected_key}")
    for reminder in sorted(set(REMINDER_ID_RE.findall(source))):
        expected_key = f"clocktower.reminder.{reminder}.text"
        if expected_key not in en_keys:
            report.error(f"en_us missing built-in reminder key: {expected_key}")
        if (
            expected_key not in ko_keys
            or not isinstance(ko_keys.get(expected_key), str)
            or not str(ko_keys.get(expected_key)).strip()
        ):
            report.error(f"ko_kr missing built-in reminder key: {expected_key}")


def check_references(
    root: Path,
    en_keys: Mapping[str, object],
    report: Report,
) -> None:
    fm_directory = root / "config" / "fancymenu" / "customization"
    datapack_directory = root / "resources" / "datapack" / "required" / "ct"
    for reference in local_key_references(fm_directory):
        if reference.key not in en_keys:
            report.error(
                f"{_relative(reference.path, root)}:{reference.line}: "
                f"FancyMenu local key is absent from en_us: {reference.key}"
            )
    for reference in datapack_translate_references(datapack_directory):
        if reference.key not in en_keys:
            report.error(
                f"{_relative(reference.path, root)}:{reference.line}: "
                f"datapack translate key is absent from en_us: {reference.key}"
            )


def _core_paths(root: Path) -> tuple[list[Path], list[Path]]:
    datapack = list(iter_files(root, root / "resources" / "datapack" / "required" / "ct", (".mcfunction", ".json", ".jsonc")))
    fm_root = root / "config" / "fancymenu" / "customization"
    fm = [
        path
        for path in iter_files(root, fm_root, (".txt",))
        if path.name.startswith("ct-") or path.name in {"chat_screen_layout.txt", "connect_screen_layout.txt"}
    ]
    return datapack, fm


def check_hardcoded_text(root: Path, report: Report) -> None:
    datapack_paths, fm_paths = _core_paths(root)
    findings: list[HardcodedText] = []
    for path in datapack_paths:
        findings.extend(find_hardcoded_datapack(path))
    for path in fm_paths:
        findings.extend(find_hardcoded_fancymenu(path))

    for finding in findings:
        location = f"{_relative(finding.path, root)}:{finding.line}"
        report.error(f"{location}: hardcoded user-facing English: {finding.text!r}")


def run_checks(root: Path, en_path: Path | None = None, ko_path: Path | None = None) -> Report:
    en_path = en_path or root / "resources" / "resourcepack" / "required" / "Blood on the Clocktower" / "assets" / "minecraft" / "lang" / "en_us.json"
    ko_path = ko_path or en_path.with_name("ko_kr.json")
    report = Report()
    en_keys, _ = check_language_files(en_path, ko_path, report)
    if en_keys:
        # Re-read Korean keys only when the English file parsed successfully;
        # check_language_files returns an empty map when the Korean file is
        # absent or malformed.
        try:
            ko_keys = read_jsonc(ko_path).data
        except (OSError, JsoncError):
            ko_keys = {}
        check_character_keys(root, en_keys, ko_keys, report)
        check_references(root, en_keys, report)
    check_hardcoded_text(root, report)
    return report


def _self_test() -> None:
    sample = r'''{
      "url": "https://example.test/a//b", // line comment
      "block": "/* not a comment */",
      /* block
         comment */
      "message": "hello\\nworld §a %1$s"
    }'''
    parsed = parse_jsonc(sample)
    assert parsed.data["url"] == "https://example.test/a//b"
    assert parsed.data["block"] == "/* not a comment */"
    assert parsed.data["message"] == r"hello\nworld §a %1$s"
    duplicate = parse_jsonc('{"x": 1, "x": 2}')
    assert duplicate.duplicate_keys == ("x",)
    assert format_tokens("%s\n§a") == format_tokens("%s\n§a")
    assert format_tokens("%s") != format_tokens("%d")
    assert _looks_like_user_english('prefix {"placeholder":"getvariable"}')
    assert not _looks_like_user_english('%!!unlovable%this is a custom font %!!arial%this is a custom font')
    assert not _looks_like_user_english('{"placeholder":"local","values":{"key":"clocktower.ui.x"}}')
    assert TEXT_FIELD_RE.findall('{"text":"Hello there"}') == ["Hello there"]
    assert DIRECT_TELLRAW_RE.search('tellraw @s "Hello there"').group(1) == "Hello there"
    assert [m.group(1) for m in TRANSLATE_KEY_RE.finditer('{"translate":"clocktower.ui.x"} translate:"clocktower.ui.y"')] == [
        "clocktower.ui.x",
        "clocktower.ui.y",
    ]
    night_sample = '\t\t"sample": {\\\n\t\t\t"first": "Show \\\"YES\\\".",\\\n\t\t\t"first_night_key": "clocktower.role.sample.first_night"\\\n\t\t},\\\n'
    assert character_fields(night_sample) == {
        "sample": {
            "first": 'Show "YES".',
            "first_night_key": "clocktower.role.sample.first_night",
        }
    }
    print("self-test: ok")


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, help="repository root (default: parent of scripts/)")
    parser.add_argument("--en", dest="en_path", type=Path, help="override en_us.json path")
    parser.add_argument("--ko", dest="ko_path", type=Path, help="override ko_kr.json path")
    parser.add_argument("--self-test", action="store_true", help="run parser self-tests and exit")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    # Minecraft strings contain section signs and icon glyphs.  Keep reports
    # printable on Windows consoles whose legacy code page cannot encode them.
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(errors="backslashreplace")
        except (AttributeError, OSError):
            pass
    args = _build_parser().parse_args(argv)
    if args.self_test:
        _self_test()
        return 0
    root = (args.root or Path(__file__).resolve().parents[1]).resolve()
    en_path = args.en_path
    ko_path = args.ko_path
    if en_path is not None and not en_path.is_absolute():
        en_path = root / en_path
    if ko_path is not None and not ko_path.is_absolute():
        ko_path = root / ko_path
    report = run_checks(root, en_path, ko_path)

    status = "FAIL" if report.errors else "PASS"
    print(f"localization check: {status} ({len(report.errors)} errors, {len(report.warnings)} warnings)")
    for message in report.errors:
        print(f"ERROR: {message}")
    for message in report.warnings:
        print(f"WARNING: {message}")
    return 1 if report.errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
