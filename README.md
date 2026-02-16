# sebat-duls

One-shot macOS bootstrap script. Run `init.sh` on a fresh Mac and walk away.

Inspired by [dmtrxw/sebats-duls](https://github.com/dmtrxw/sebats-duls).

## What it does

Sets up a full dev environment in one command:

- **Shell** — zsh + oh-my-zsh + powerlevel10k + autosuggestions + syntax-highlighting
- **Terminal** — Ghostty (coolnight theme, cursor shaders) + tmux (oh-my-tmux)
- **Editor** — Neovim + LazyVim (night-owl, TypeScript + Solidity tooling)
- **Browser** — qutebrowser (Night Owl theme, CDP proxy, YT ad bypass)
- **Claude Code** — hooks, sounds, keybindings, custom slash commands
- **Languages** — Node (nvm + bun + pnpm), Rust, Python
- **Blockchain** — Foundry, Solana, Anchor
- **CLI tools** — lazygit, fzf, fd, btop, htop, gh, and more via Homebrew

## Usage

```bash
git clone https://github.com/alkautsarf/sebat-duls.git
cd sebat-duls
chmod +x init.sh
./init.sh
```

### Dry run

Preview everything without making changes:

```bash
./init.sh --dry-run
```

## How it works

Configs are **symlinked**, not copied. Your live configs point directly to files in this repo:

```
~/.zshrc → sebat-duls/dotfiles/.zshrc
~/.config/nvim → sebat-duls/config/nvim
~/.claude/settings.json → sebat-duls/claude/settings.json
```

This means:
- Edit a config anywhere and the change is already in the repo
- `git diff` shows exactly what changed
- `git commit` to save, `git push` to sync across machines

### Safety

- Existing configs are backed up to `~/.sebat-duls-backup/<timestamp>/` before overwriting
- Already-installed tools are skipped (idempotent)
- User confirmation prompt before any changes
- `set -e` stops on first error

## Repo structure

```
sebat-duls/
├── init.sh                     # Bootstrap script
├── dotfiles/
│   ├── .zshrc                  # Shell config (p10k, nvm, aliases)
│   ├── .zprofile               # Login shell PATH
│   ├── .zshenv                 # Foundry + Cargo PATH
│   ├── .p10k.zsh               # Powerlevel10k prompt config
│   ├── .tmux.conf.local        # oh-my-tmux overrides
│   ├── .gitconfig              # Git settings
│   └── .gitignore_global       # Global gitignore
├── config/
│   ├── nvim/                   # LazyVim config (night-owl, 40+ plugins)
│   ├── ghostty/config          # Ghostty terminal config
│   ├── btop/btop.conf
│   ├── htop/htoprc
│   ├── karabiner/karabiner.json
│   ├── Yatoro/config.yaml      # Apple Music TUI
│   └── gh/config.yml           # GitHub CLI
├── qutebrowser/
│   ├── config.py               # Browser config
│   ├── force-font.css          # Custom font stylesheet
│   ├── quickmarks              # Bookmarks
│   ├── greasemonkey/           # Userscripts
│   └── scripts/qb_proxy.py    # CDP proxy script
├── claude/
│   ├── settings.json           # Claude Code settings
│   ├── CLAUDE.md               # Global instructions
│   ├── keybindings.json        # Key remaps
│   └── commands/               # Slash commands (commit, tweet)
├── sounds/                     # Notification sounds (5 .wav files)
└── ssh/config                  # SSH config (no keys)
```

## Post-install

After running `init.sh`:

1. Restart your terminal (or `source ~/.zshrc`)
2. Open `nvim` once to auto-install plugins
3. Generate SSH keys: `ssh-keygen -t ed25519`
4. Update the Tailscale IP placeholder in `ssh/config`

## Fonts

The script installs two font families:

- **Ioskeley Mono** — main font for Ghostty + qutebrowser
- **MesloLGS NF** — powerlevel10k prompt glyphs

## Theme

Everything shares a consistent Night Owl-inspired palette:

| Component   | Background | Foreground |
|-------------|-----------|------------|
| Ghostty     | `#010c18` | `#ecdef5`  |
| tmux        | `#010c18` | `#c0caf5`  |
| Neovim      | night-owl theme         |
| qutebrowser | `#010c18` | `#d6deeb`  |

Selection accent: `#38ff9c`
