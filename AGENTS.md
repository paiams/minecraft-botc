# Agent Working Rules

- Write repository documentation in English; preserve localized game content.
- Do not push, publish releases, change remote settings, or create/delete remote
  branches unless explicitly requested. Local work is not permission to publish.
- Do not rewrite published history, move existing release tags, or delete branches
  without explicit authorization for the affected scope.
- Do not contact upstream or artists, or submit upstream issues or pull requests,
  without the owner's explicit request. Respect upstream contribution policies.
- Preserve unrelated user changes. Back up deployment targets and stop the relevant
  client or server before replacing runtime files. Do not automate the Modrinth UI.
- Keep runtime files, worlds, logs, credentials and personal settings out of commits.

## Subagents

- Do not delegate trivial or tightly coupled work.
- Use the configured default agent unless a specific agent or model is requested.
- When explicitly requested, use the `deepseek` custom agent for DeepSeek.
- Wait for delegated work to finish and integrate its results.
