# Working agreement

- Keep work small and tied to the user's current request. Finish the requested batch, verify, summarize briefly, then stop. Do not invent background work or poll idle Studio.
- Minimize AI usage: targeted file reads, bounded searches/logs, and only relevant MCP tools. Do not dump complete tool catalogs or whole game trees. No agents or recurring jobs unless explicitly requested.
- Read docs/STATUS.md for current state; read other docs only when relevant. Keep this file short.
- Source of truth for scripts: src/ via Rojo. Make script edits on disk, not only in Studio. World art/terrain lives in the Studio place; mapped objects in default.project.json are owned by Rojo.
- Use plain Luau with --!strict. Server owns rewards, inventory, saving, and validation. Never trust client-supplied values or store secrets in shared/client code.
- Prefer small ModuleScripts and Roblox services. Add packages/frameworks only when a concrete feature needs them. No paid services, AI APIs, or game monetization during setup.
- Run scripts/check.cmd for source/project changes; run a focused Studio playtest for runtime changes. Do not add tests for trivial configuration or merely mirror implementation.
- Avoid simultaneous edits to the same file/object as the user. Preserve unrelated Studio content. Use undo recordings for direct world edits when supported.
- Update docs/STATUS.md with meaningful changes and unresolved issues. Report what changed, validation, and remaining limits in a few bullets.
- Never publish, spend Robux, or push to a remote without user authorization. Local editing and checks are authorized.
