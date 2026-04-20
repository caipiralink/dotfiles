<img src="assets/dotfiles-banner.svg" alt="dotfiles" width="100%">

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Built from scratch — I prefer configs I actually understand over copying large setups I can't maintain. Work in progress.

Uses 1Password for SSH keys and Git signing — no secrets stored in the repo.

## Setup

Some values (Git identity, 1Password vault references, APT mirror, etc.) are hardcoded for my environment. Fork and adjust before using.

```bash
chezmoi init --apply caipira113/dotfiles
```

Chezmoi will ask whether this is a personal or work machine and configure Git identity accordingly.

## Contents

| Config | Target | Description |
|---|---|---|
| [`dot_zshrc`](dot_zshrc) | `~/.zshrc` | Zsh with [Zinit](https://github.com/zdharma-continuum/zinit) — completions, autosuggestions, syntax highlighting. Aliases on `eza`. Tool activation (mise, starship, fzf, uv, kubectl, helm, gcloud) conditional via `command -v`. |
| [`dot_gitconfig.tmpl`](dot_gitconfig.tmpl) | `~/.gitconfig` | SSH commit signing via 1Password. Personal/work identity templated by chezmoi. Signing program path adapts to OS. |
| [`starship.toml`](private_dot_config/starship.toml) | `~/.config/starship.toml` | Minimal — only overrides Node.js detection to `package.json` / `.node-version` / `node_modules`. |
| [`nvim/`](private_dot_config/nvim/) | `~/.config/nvim/` | Single-file Neovim config with lazy.nvim. [→ details](private_dot_config/nvim/README.md) |
| [`mise/`](private_dot_config/mise/) | `~/.config/mise/` | 30+ dev tools managed by mise. [→ full list](private_dot_config/mise/README.md) |
| [`distrobox/`](private_dot_config/distrobox/) | `~/.config/distrobox/` | Debian Trixie dev container provisioning. [→ details](private_dot_config/distrobox/README.md) |
| [`1Password/`](private_dot_config/1Password/) | `~/.config/1Password/ssh/` | SSH agent vault selection — personal: `SSH agent` only, work: adds `Work` vault. |
| [`dot_claude/`](dot_claude/) | `~/.claude/` | Claude Code global instructions and settings. `env.CLAUDE_CODE_GIT_BASH_PATH` is Windows-only via template. |

## License

[Unlicense](LICENSE)
