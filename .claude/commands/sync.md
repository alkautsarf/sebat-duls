# Sync Check (live → repo)

Diff every live config against its repo counterpart to find changes that need to be synced INTO the repo. Do NOT make any changes — only report.

The goal is to catch config updates made on the live machine that haven't been committed to the repo yet.

## Config pairs to check

Run `diff` for each pair (repo file on the left, live file on the right):

### Shell & Terminal
- `dotfiles/.zshrc` vs `~/.zshrc`
- `dotfiles/.zprofile` vs `~/.zprofile`
- `dotfiles/.zshenv` vs `~/.zshenv`
- `dotfiles/.p10k.zsh` vs `~/.p10k.zsh`
- `dotfiles/.tmux.conf.local` vs `~/.tmux.conf.local`
- `dotfiles/.gitconfig` vs `~/.gitconfig`
- `dotfiles/.gitignore_global` vs `~/.gitignore_global`

### App configs
- `config/ghostty/config` vs `~/Library/Application Support/com.mitchellh.ghostty/config`
- `config/nvim/` vs `~/.config/nvim/` (use `diff -rq`, exclude `.git`, `lazy-lock.json`, `.cache`, `.nvimlog`, `.neoconf.json`, `LICENSE`, `README.md`)
- `config/btop/btop.conf` vs `~/.config/btop/btop.conf`
- `config/htop/htoprc` vs `~/.config/htop/htoprc`
- `config/karabiner/karabiner.json` vs `~/.config/karabiner/karabiner.json`
- `config/Yatoro/config.yaml` vs `~/.config/Yatoro/config.yaml`
- `config/gh/config.yml` vs `~/.config/gh/config.yml`

### Claude Code
- `claude/settings.json` vs `~/.claude/settings.json` (ignore the `permissions.allow` array — it bloats with project-specific entries)
- `claude/statusline.sh` vs `~/.claude/statusline.sh`
- `claude/keybindings.json` vs `~/.claude/keybindings.json`
- `claude/CLAUDE.md` vs `~/.claude/CLAUDE.md`
- `claude/commands/` vs `~/.claude/commands/` (use `diff -rq`)

### Qutebrowser
- `qutebrowser/config.py` vs `~/.qutebrowser/config.py`
- `qutebrowser/force-font.css` vs `~/.qutebrowser/force-font.css`
- `qutebrowser/quickmarks` vs `~/.qutebrowser/quickmarks`

### SSH
- `ssh/config` vs `~/.ssh/config` (repo uses `<TAILSCALE_IP>` placeholder — ignore IP differences)

## Known acceptable differences (ignore these)

- **Absolute paths vs `$HOME`**: The repo uses portable `$HOME`, live may have expanded `/Users/alkautsar/...`. Only flag if there are actual content differences beyond path style.
- **`claude/settings.json` permissions.allow**: Skip entirely, it accumulates project-specific entries.
- **`claude/settings.json` sound paths**: `~/` vs absolute — cosmetic, ignore.
- **`claude/settings.json` empty arrays**: Repo may have `"PostToolUse": []` while live omits the key — ignore.
- **`ssh/config` Tailscale IP**: Repo uses placeholder, live has real IP — ignore.
- **`nvim/` stale files**: Files only in live (backups, tarballs, .bak files) are cleanup items, not sync items.

## Output format

For each pair:
- If identical or only acceptable differences: skip (don't mention)
- If different with meaningful changes: show the file pair and a brief summary of what changed in the live version
- If live file doesn't exist: skip (not relevant for live → repo sync)

At the end, list all files with meaningful drift and ask which ones to copy from live into the repo and commit.
