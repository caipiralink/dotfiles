# cursor-supermemory vendored plugin

This directory vendors the Cursor Supermemory plugin for deployment through chezmoi.

Source repository: https://github.com/supermemoryai/cursor-supermemory.git
Source commit: 95b625c9662866f6c89cf556a54b918b2b2e2bf1

The `dist/` files were built from that commit with:

```bash
bun install --frozen-lockfile
bun run build
```

The bundled MCP server is configured to run the vendored `dist/cli.js` with the `mcp` command instead of using `bunx cursor-supermemory@latest`.
