# Local eight-player test controls

Use `/botc_test` as the Storyteller on the local Carpet-enabled server.
Do not use these controls during a real game. Other real participants block setup,
day progression, automatic voting and teardown.

- **8-player setup** (`/botc_test setup`): shows a confirmation link. Confirming
  resets the current game and connects eight Carpet fake players. After three
  seconds, seats and a fixed 5/1/1/1 role distribution are prepared before night one.
  The saved configuration bag is not overwritten. Use the grimoire to test seat
  swaps and role changes at this point.
- **First day** (`/botc_test day`): runs the normal game-start function, then
  advances through dawn to daytime and moves the bots to their seats.
- **Automatic vote** (`/botc_test vote <yes:0..8> <seat:1..8>`): nominates the
  selected seat, runs the normal vote-toggle function for the first N seats,
  leaves four seconds to inspect the HUD, then starts the normal timed vote.
  It does not set the execution candidate directly. Requires eight living bots.
- **Stop** (`/botc_test stop`): cancels pending test/vote work, resets the test
  game and disconnects only tagged test bots. It does not restore a previous game.

Suggested sequence: 3 votes for seat 2 (no candidate), 4 for seat 2 (candidate),
4 for seat 3 (tie clears candidate), 5 for seat 4 (new candidate).
Open the quick-actions menu and select a face under teleport home to test `/botc_home`.
The resource pack displays execution particles as red skulls.

Back up the world before testing if its current state needs to be preserved.
Deploy with `sync-dev.cmd` after shutting down both Minecraft and the server.

Static checks: `python scripts/check_test_controls.py` and
`python scripts/check_vote_result.py`. These do not replace the in-game checks.

## Verified locally (2026-09-10)

- Eight fake players connected and pregame preparation completed (`#test_count=8`,
  `#prepared=1`). Account `efe` must use its canonical lowercase spelling.
- Set all eight Korean display names with `displayname setfor` commands.
- Clicked home faces for seats 1 and 2; server positions matched both destinations.
  Removing the face buttons' horizontal tilt restored mouse clicks in FancyMenu.
- Ran the normal timed vote sequence: 3 votes produced no candidate, 4 selected
  seat 2, another 4 cleared the candidate, and 5 selected seat 4.
- Observed actual voter faces in the top HUD and red skull particles on the candidate.
- Test teardown reset phase to zero and disconnected all eight fake players.
