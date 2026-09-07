# Blood on the Clocktower Keyboard Shortcuts

Based on the local playtest Modrinth profile's `options.txt` and Chat Binds configuration as of 2026-09-07. Other players' bindings may differ. Use these shortcuts while the game has focus; when typing in chat, letter keys enter text instead.

## Game Controls

| Key | Action | Notes |
| --- | --- | --- |
| G | Open Grimoire | `/grimoire`. The screen depends on your permissions. |
| H | Open script | `/script` |
| C | Open nomination menu | `/noms_menu`. Select the nominator and nominee. |
| R | Storyteller quick actions | `/quickactions root`. Includes teleportation and execution controls. |
| T | Open chat | Storyteller progression buttons also appear here. |
| Enter | Toggle night voice chat | `/togglevc`. Switch between all-player night voice chat and private/proximity chat. |
| Tab | Show player list | Rendered by BetterTab. |
| Left / Right arrow | Scroll player list | BetterTab horizontal scrolling. |

The bag has no dedicated key in this configuration. Hold the bag item and right-click. Grimoire and script items can also be opened with right-click.

## Voice and Actions

| Key | Action |
| --- | --- |
| V | Voice chat menu |
| M | Toggle microphone mute |
| X | Sit |
| B | Emote selection menu |

Push-to-talk and voice whisper keys are **unassigned** in this configuration. Enter does not mute the microphone. If others cannot hear you, check the microphone device under V and the mute state controlled by M.

## Display and Settings

| Key | Action |
| --- | --- |
| Esc | Close menu / open pause menu |
| E | Inventory |
| F1 | Toggle HUD |
| F2 | Screenshot |
| F5 | Change camera perspective |
| N | BetterTab settings |
| O | Shader pack selection |
| K | Toggle shaders |
| R | Reload shaders — see conflict below |

## R Key Conflict

**Quick actions and Iris shader reload are both bound to R.** Pressing R may display a shader reload message or cause a brief stutter. In `Options → Controls → Key Binds`, reassign or unbind only the Iris reload action.

In Chat Binds, G/H/C/R/Enter are listed as `View Grimoire`, `View Script`, `Nomination`, `Storyteller Quick Actions`, and `Toggle Night Voice Chat`.

## Execution and Death

In this fork, execution lightning automatically invokes the existing death procedure for its target, updating the skull, death tags, and Grimoire state. Already-dead targets skip duplicate death processing.

Use **Revive** in the Grimoire if the execution was a mistake or the Storyteller decides the player should remain alive. Role-specific execution survival is not evaluated automatically. This change applies only to the modpack's execution function, not ordinary world lightning.
