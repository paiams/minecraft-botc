# Dedicated-server packet initialization

SpiffyHUD 3.1.2's Fabric main entrypoint only registers server events. Its
`SpiffyHud.init()` registers packet codecs, but that initialization is not reached
on the dedicated server in this pack. FancyMenu therefore rejects `spiffy_structures`
and `spiffy_marker_command_suggestions` with a null codec.

This server-only, metadata-only Fabric mod invokes the existing public
`Packets.registerAll` method through Fabric's default language adapter. It ships no
third-party bytecode and does not modify either original mod. Exact dependency
versions intentionally require rechecking the workaround when the mods change.

`scripts/setup_local_server.ps1` builds and verifies the JAR. It is not needed on
clients. Remove the compatibility JAR when using a version with upstream server
initialization fixed; do not carry it across versions without verification.

Regression check: run setup and `-VerifyOnly`, start the dedicated server, connect
with the matching client, and open the Grimoire and quick-actions screen repeatedly.
Both packet identifiers must be absent from new `No codec` errors. Startup alone
checks entrypoint loading but does not verify client/server packet round trips.
