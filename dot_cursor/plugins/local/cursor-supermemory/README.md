# cursor-supermemory vendored plugin

This directory vendors the Cursor Supermemory plugin for deployment through chezmoi.

Source repository: https://github.com/caipiralink/cursor-supermemory.git
Source branch: vendor/integrated
Source commit: bcccc711fbece971de0e31d3a70ccf2563979d34
Upstream: https://github.com/supermemoryai/cursor-supermemory.git

The `dist/` files were built from that source with:

```bash
bun install --frozen-lockfile
bun run build
```

Vendored changes relative to upstream main:

- `hooks/hooks.json` includes the top-level `version` field so Cursor loads the plugin hooks.
- `src/mcp-server.ts` resolves the workspace root from `SUPERMEMORY_WORKSPACE_ROOT` (injected via `${workspaceFolder}`) instead of `process.cwd()`, so project memory containers stay scoped per workspace.

The bundled MCP server runs the vendored `dist/cli.js` with the `mcp` command instead of `bunx cursor-supermemory@latest`, and `mcp.json` injects `SUPERMEMORY_WORKSPACE_ROOT` from `${workspaceFolder}`.
