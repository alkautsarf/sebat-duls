#!/bin/bash
# ═══════════════════════════════════════════════════════════
# sebat-duls — elpabl0's macOS bootstrap script
# inspired by dmtrxw's sebats-duls
# ═══════════════════════════════════════════════════════════
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.sebat-duls-backup/$(date +%Y%m%d-%H%M%S)"

# ─── dry-run flag ──────────────────────────────────────────

DRY_RUN=false
[[ "$1" == "--dry-run" ]] && DRY_RUN=true

# ─── helpers ──────────────────────────────────────────────

info()  { printf "\033[38;5;51m[info]\033[0m  %s\n" "$1"; }
ok()    { printf "\033[38;5;34m[ok]\033[0m    %s\n" "$1"; }
warn()  { printf "\033[38;5;220m[warn]\033[0m  %s\n" "$1"; }
skip()  { printf "\033[38;5;247m[skip]\033[0m  %s\n" "$1"; }
dry()   { printf "\033[38;5;213m[dry]\033[0m   %s\n" "$1"; }

# run a command (or print it in dry-run mode)
run() {
  if $DRY_RUN; then
    dry "$*"
  else
    "$@"
  fi
}

backup() {
  local src="$1"
  if [ -e "$src" ] || [ -L "$src" ]; then
    if $DRY_RUN; then
      dry "would back up $src → $BACKUP_DIR/"
    else
      mkdir -p "$BACKUP_DIR"
      cp -a "$src" "$BACKUP_DIR/"
      info "backed up $src → $BACKUP_DIR/"
    fi
  fi
}

safe_link() {
  local src="$1" dest="$2"
  backup "$dest"
  if $DRY_RUN; then
    dry "link $dest → $src"
  else
    mkdir -p "$(dirname "$dest")"
    # remove existing dir (already backed up) so symlink can replace it
    [ -d "$dest" ] && [ ! -L "$dest" ] && rm -rf "$dest"
    ln -sfn "$src" "$dest"
    ok "linked $dest → $src"
  fi
}

clone_if_missing() {
  local repo="$1" dest="$2"
  if [ -d "$dest" ]; then
    skip "$dest already exists"
  else
    if $DRY_RUN; then
      dry "git clone $repo → $dest"
    else
      git clone "$repo" "$dest"
      ok "cloned $repo → $dest"
    fi
  fi
}

# ─── confirmation ─────────────────────────────────────────

echo ""
echo "  ╔═══════════════════════════════════════╗"
if $DRY_RUN; then
echo "  ║   sebat-duls — DRY RUN MODE          ║"
else
echo "  ║   sebat-duls — elpabl0's bootstrap    ║"
fi
echo "  ╚═══════════════════════════════════════╝"
echo ""
echo "  this will set up your mac with:"
echo "    - homebrew + cli tools"
echo "    - ghostty + tmux + zsh + p10k"
echo "    - neovim + lazyvim"
echo "    - qutebrowser + cdp proxy"
echo "    - claude code"
echo "    - node (lts) + python + rust"
echo "    - foundry + solana"
echo ""
echo "  configs will be symlinked to this repo."
echo "  existing configs will be backed up to:"
echo "    $BACKUP_DIR"
echo ""
if $DRY_RUN; then
  info "dry-run mode: no changes will be made"
  echo ""
else
  read -rp "  proceed? (y/n) " answer
  if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "  aborted."
    exit 0
  fi
fi
echo ""

# ═══════════════════════════════════════════════════════════
# 1. xcode command line tools
# ═══════════════════════════════════════════════════════════

info "checking xcode cli tools..."
if ! xcode-select -p &>/dev/null; then
  if $DRY_RUN; then
    dry "xcode-select --install"
  else
    xcode-select --install
    echo "  waiting for xcode cli tools to finish installing..."
    until xcode-select -p &>/dev/null; do sleep 5; done
    ok "xcode cli tools installed"
  fi
else
  skip "xcode cli tools already installed"
fi

# ═══════════════════════════════════════════════════════════
# 2. homebrew
# ═══════════════════════════════════════════════════════════

info "checking homebrew..."
if ! command -v brew &>/dev/null; then
  if $DRY_RUN; then
    dry "install homebrew via curl"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ok "homebrew installed"
  fi
else
  skip "homebrew already installed"
fi
if ! $DRY_RUN; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ═══════════════════════════════════════════════════════════
# 3. homebrew taps
# ═══════════════════════════════════════════════════════════

info "adding brew taps..."
TAPS=(
  jayadamsmorgan/yatoro
  anomalyco/tap
)
for tap in "${TAPS[@]}"; do
  if ! $DRY_RUN && brew tap | grep -q "^${tap}$"; then
    skip "tap $tap"
  else
    run brew tap "$tap"
    $DRY_RUN || ok "tapped $tap"
  fi
done

# ═══════════════════════════════════════════════════════════
# 4. homebrew formulae
# ═══════════════════════════════════════════════════════════

info "installing brew formulae..."
FORMULAE=(
  # core cli
  neovim tmux fzf fd lazygit btop htop gh git-lfs
  wget curl gnu-tar imagemagick pandoc cloc tree-sitter-cli
  viu terminal-notifier asciinema duti cloudflared watchman make
  # languages
  nvm pnpm
  # music
  nowplaying-cli
  # other
  mole podman
)

for formula in "${FORMULAE[@]}"; do
  if ! $DRY_RUN && brew list "$formula" &>/dev/null; then
    skip "$formula"
  else
    run brew install "$formula"
    $DRY_RUN || ok "$formula"
  fi
done

# set up git lfs
run git lfs install 2>/dev/null || true

# tap-specific formulae
for formula in anomalyco/tap/opencode jayadamsmorgan/yatoro/yatoro; do
  if ! $DRY_RUN && brew list "$formula" &>/dev/null; then
    skip "$formula"
  else
    run brew install "$formula"
    $DRY_RUN || ok "$formula"
  fi
done

# ═══════════════════════════════════════════════════════════
# 5. homebrew casks
# ═══════════════════════════════════════════════════════════

info "installing brew casks..."
CASKS=(ghostty tailscale-app)
for cask in "${CASKS[@]}"; do
  if ! $DRY_RUN && brew list --cask "$cask" &>/dev/null; then
    skip "$cask"
  else
    run brew install --cask "$cask"
    $DRY_RUN || ok "$cask"
  fi
done

# ═══════════════════════════════════════════════════════════
# 6. ffmpeg
# ═══════════════════════════════════════════════════════════

info "installing ffmpeg..."
if ! $DRY_RUN && brew list ffmpeg &>/dev/null; then
  skip "ffmpeg already installed"
else
  run brew install ffmpeg
  $DRY_RUN || ok "ffmpeg"
fi

# ═══════════════════════════════════════════════════════════
# 7. fonts
# ═══════════════════════════════════════════════════════════

info "installing fonts..."
FONT_DIR="$HOME/Library/Fonts"
$DRY_RUN || mkdir -p "$FONT_DIR"

# ioskeley mono
if [ -f "$FONT_DIR/IoskeleyMono-Regular.ttf" ]; then
  skip "ioskeley mono already installed"
else
  if $DRY_RUN; then
    dry "download ioskeley mono from GitHub releases → $FONT_DIR/"
  else
    TMPDIR_FONT=$(mktemp -d)
    info "downloading ioskeley mono..."
    RELEASE_URL=$(curl -s https://api.github.com/repos/ahatem/IoskeleyMono/releases/latest | grep "browser_download_url.*zip" | head -1 | cut -d'"' -f4)
    if [ -n "$RELEASE_URL" ]; then
      curl -sL "$RELEASE_URL" -o "$TMPDIR_FONT/ioskeley.zip"
      unzip -qo "$TMPDIR_FONT/ioskeley.zip" -d "$TMPDIR_FONT/ioskeley"
      find "$TMPDIR_FONT/ioskeley" -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
      ok "ioskeley mono installed"
    else
      warn "could not find ioskeley mono release, skipping"
    fi
    rm -rf "$TMPDIR_FONT"
  fi
fi

# meslolgs nf (for powerlevel10k)
if [ -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
  skip "meslolgs nf already installed"
else
  if $DRY_RUN; then
    dry "download MesloLGS NF (4 variants) → $FONT_DIR/"
  else
    info "downloading meslolgs nf..."
    MESLO_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"
    for variant in "MesloLGS NF Regular" "MesloLGS NF Bold" "MesloLGS NF Italic" "MesloLGS NF Bold Italic"; do
      curl -sL "$MESLO_BASE/${variant// /%20}.ttf" -o "$FONT_DIR/$variant.ttf"
    done
    ok "meslolgs nf installed"
  fi
fi

# ═══════════════════════════════════════════════════════════
# 8. shell setup (oh-my-zsh + p10k + plugins)
# ═══════════════════════════════════════════════════════════

info "setting up shell..."

# oh-my-zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
  skip "oh-my-zsh already installed"
else
  if $DRY_RUN; then
    dry "install oh-my-zsh via curl"
  else
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ok "oh-my-zsh installed"
  fi
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# powerlevel10k
clone_if_missing "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"

# plugins
clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# dotfiles
safe_link "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
safe_link "$DOTFILES_DIR/dotfiles/.zprofile" "$HOME/.zprofile"
safe_link "$DOTFILES_DIR/dotfiles/.zshenv" "$HOME/.zshenv"
safe_link "$DOTFILES_DIR/dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"

# ═══════════════════════════════════════════════════════════
# 9. tmux setup (oh-my-tmux)
# ═══════════════════════════════════════════════════════════

info "setting up tmux..."

clone_if_missing "https://github.com/gpakosz/.tmux.git" "$HOME/.tmux"
safe_link "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
safe_link "$DOTFILES_DIR/dotfiles/.tmux.conf.local" "$HOME/.tmux.conf.local"

# ═══════════════════════════════════════════════════════════
# 10. nvm + node + bun + claude code
# ═══════════════════════════════════════════════════════════

info "setting up node..."

# source nvm (homebrew installs to $(brew --prefix)/opt/nvm/)
export NVM_DIR="$HOME/.nvm"
$DRY_RUN || mkdir -p "$NVM_DIR"
if ! $DRY_RUN; then
  if [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ]; then
    . "$(brew --prefix)/opt/nvm/nvm.sh"
  elif [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
  fi
fi

if $DRY_RUN; then
  dry "nvm install --lts && nvm alias default lts/*"
elif command -v nvm &>/dev/null; then
  nvm install --lts || true
  nvm alias default 'lts/*' || true
  ok "node lts installed"
else
  warn "nvm not available yet — run 'source ~/.zshrc' then 'nvm install --lts'"
fi

# bun
if ! $DRY_RUN && command -v bun &>/dev/null; then
  skip "bun already installed"
else
  if $DRY_RUN; then
    dry "curl -fsSL https://bun.sh/install | bash"
  else
    curl -fsSL https://bun.sh/install | bash
    ok "bun installed"
  fi
fi

# claude code
if ! $DRY_RUN && command -v claude &>/dev/null; then
  skip "claude code already installed"
else
  if $DRY_RUN; then
    dry "npm install -g @anthropic-ai/claude-code"
  elif command -v npm &>/dev/null; then
    npm install -g @anthropic-ai/claude-code
    ok "claude code installed"
  else
    warn "npm not available — install claude code after 'nvm install --lts'"
  fi
fi

# ═══════════════════════════════════════════════════════════
# 11. python setup (qutebrowser deps)
# ═══════════════════════════════════════════════════════════

info "installing python packages for qutebrowser..."
if ! $DRY_RUN && command -v qutebrowser &>/dev/null; then
  skip "qutebrowser already installed"
else
  if $DRY_RUN; then
    dry "pip3 install --user PyQt6 PyQt6-WebEngine qutebrowser aiohttp"
  else
    pip3 install --user --break-system-packages PyQt6 PyQt6-WebEngine qutebrowser aiohttp 2>/dev/null || \
    pip3 install --user PyQt6 PyQt6-WebEngine qutebrowser aiohttp
    ok "qutebrowser + deps installed"
  fi
fi

# ═══════════════════════════════════════════════════════════
# 12. rust + blockchain
# ═══════════════════════════════════════════════════════════

info "setting up rust + blockchain tools..."

# rust
if ! $DRY_RUN && command -v rustc &>/dev/null; then
  skip "rust already installed"
else
  if $DRY_RUN; then
    dry "install rust via rustup"
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    ok "rust installed"
  fi
fi
# ensure cargo is on PATH for this session
if ! $DRY_RUN; then
  [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
fi

# foundry
if ! $DRY_RUN && command -v forge &>/dev/null; then
  skip "foundry already installed"
else
  if $DRY_RUN; then
    dry "install foundry via foundryup"
  else
    curl -L https://foundry.paradigm.xyz | bash
    export PATH="$HOME/.foundry/bin:$PATH"
    foundryup
    ok "foundry installed"
  fi
fi

# solana
if ! $DRY_RUN && command -v solana &>/dev/null; then
  skip "solana cli already installed"
else
  if $DRY_RUN; then
    dry "install solana cli via anza.xyz"
  else
    sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"
    ok "solana cli installed"
  fi
fi
# ensure solana is on PATH for anchor install
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# anchor (via avm)
if ! $DRY_RUN && command -v anchor &>/dev/null; then
  skip "anchor already installed"
else
  if $DRY_RUN; then
    dry "cargo install anchor avm && avm install latest"
  elif command -v cargo &>/dev/null; then
    cargo install --git https://github.com/coral-xyz/anchor avm --force
    avm install latest
    avm use latest
    ok "anchor installed"
  else
    warn "cargo not available — install anchor after rust setup"
  fi
fi

# ═══════════════════════════════════════════════════════════
# 13. neovim config
# ═══════════════════════════════════════════════════════════

info "setting up neovim config..."
$DRY_RUN || mkdir -p "$HOME/.config"
safe_link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
$DRY_RUN || ok "neovim config linked (run nvim once to auto-install plugins)"

# ═══════════════════════════════════════════════════════════
# 14. ghostty config + shaders
# ═══════════════════════════════════════════════════════════

info "setting up ghostty config..."
GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
$DRY_RUN || mkdir -p "$GHOSTTY_DIR"
safe_link "$DOTFILES_DIR/config/ghostty/config" "$GHOSTTY_DIR/config"

# cursor shaders
if [ -d "$GHOSTTY_DIR/shaders" ]; then
  skip "ghostty shaders already exist"
else
  if $DRY_RUN; then
    dry "git clone ghostty-cursor-shaders → $GHOSTTY_DIR/shaders"
  else
    git clone https://github.com/sahaj-b/ghostty-cursor-shaders "$GHOSTTY_DIR/shaders"
    ok "ghostty cursor shaders installed"
  fi
fi

# ═══════════════════════════════════════════════════════════
# 15. qutebrowser config (VERBATIM — do not modify)
# ═══════════════════════════════════════════════════════════

info "setting up qutebrowser config..."
if ! $DRY_RUN; then
  mkdir -p "$HOME/.qutebrowser/greasemonkey"
  mkdir -p "$HOME/.config/qutebrowser/scripts"
fi

safe_link "$DOTFILES_DIR/qutebrowser/config.py" "$HOME/.qutebrowser/config.py"
safe_link "$DOTFILES_DIR/qutebrowser/force-font.css" "$HOME/.qutebrowser/force-font.css"
safe_link "$DOTFILES_DIR/qutebrowser/quickmarks" "$HOME/.qutebrowser/quickmarks"
safe_link "$DOTFILES_DIR/qutebrowser/greasemonkey/youtube-ad-fast-forward.user.js" "$HOME/.qutebrowser/greasemonkey/youtube-ad-fast-forward.user.js"
safe_link "$DOTFILES_DIR/qutebrowser/scripts/qb_proxy.py" "$HOME/.config/qutebrowser/scripts/qb_proxy.py"

# ═══════════════════════════════════════════════════════════
# 16. claude code config
# ═══════════════════════════════════════════════════════════

info "setting up claude code config..."
$DRY_RUN || mkdir -p "$HOME/.claude/commands"

safe_link "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
safe_link "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
safe_link "$DOTFILES_DIR/claude/keybindings.json" "$HOME/.claude/keybindings.json"
safe_link "$DOTFILES_DIR/claude/commands/commit.md" "$HOME/.claude/commands/commit.md"
safe_link "$DOTFILES_DIR/claude/commands/tweet.md" "$HOME/.claude/commands/tweet.md"

# ═══════════════════════════════════════════════════════════
# 17. misc configs
# ═══════════════════════════════════════════════════════════

info "setting up misc configs..."
safe_link "$DOTFILES_DIR/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"
safe_link "$DOTFILES_DIR/config/htop/htoprc" "$HOME/.config/htop/htoprc"
safe_link "$DOTFILES_DIR/config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
safe_link "$DOTFILES_DIR/config/Yatoro/config.yaml" "$HOME/.config/Yatoro/config.yaml"
safe_link "$DOTFILES_DIR/config/gh/config.yml" "$HOME/.config/gh/config.yml"

# ═══════════════════════════════════════════════════════════
# 18. git config
# ═══════════════════════════════════════════════════════════

info "setting up git config..."
safe_link "$DOTFILES_DIR/dotfiles/.gitconfig" "$HOME/.gitconfig"
safe_link "$DOTFILES_DIR/dotfiles/.gitignore_global" "$HOME/.gitignore_global"

# ═══════════════════════════════════════════════════════════
# 19. ssh config
# ═══════════════════════════════════════════════════════════

info "setting up ssh config..."
if $DRY_RUN; then
  dry "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
  dry "chmod 600 $DOTFILES_DIR/ssh/config"
else
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  chmod 600 "$DOTFILES_DIR/ssh/config"
fi
safe_link "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"

# ═══════════════════════════════════════════════════════════
# 20. sounds
# ═══════════════════════════════════════════════════════════

info "linking sounds..."
$DRY_RUN || mkdir -p "$HOME/Library/Sounds"
for wav in "$DOTFILES_DIR/sounds/"*.wav; do
  if $DRY_RUN; then
    dry "link ~/Library/Sounds/$(basename "$wav") → $wav"
  else
    ln -sf "$wav" "$HOME/Library/Sounds/$(basename "$wav")"
  fi
done
$DRY_RUN || ok "sound files linked"

# ═══════════════════════════════════════════════════════════
# 21. extra repos
# ═══════════════════════════════════════════════════════════

info "cloning extra repos..."

# yatoro (apple music controls)
$DRY_RUN || mkdir -p "$HOME/Documents/music"
clone_if_missing "https://github.com/jayadamsmorgan/Yatoro" "$HOME/Documents/music/Yatoro-Fire"

# elsummariz00r (qutebrowser userscripts)
clone_if_missing "https://github.com/alkautsarf/elsummariz00r" "$HOME/Documents/elsummariz00r"

# symlink userscripts
USERSCRIPTS_DIR="$HOME/.local/share/qutebrowser/userscripts"
$DRY_RUN || mkdir -p "$USERSCRIPTS_DIR"
if $DRY_RUN; then
  dry "link $USERSCRIPTS_DIR/summarize → elsummariz00r/bin/qb-summarize"
  dry "link $USERSCRIPTS_DIR/discuss → elsummariz00r/bin/qb-discuss"
elif [ -f "$HOME/Documents/elsummariz00r/bin/qb-summarize" ]; then
  ln -sf "$HOME/Documents/elsummariz00r/bin/qb-summarize" "$USERSCRIPTS_DIR/summarize"
  ln -sf "$HOME/Documents/elsummariz00r/bin/qb-discuss" "$USERSCRIPTS_DIR/discuss"
  ok "qutebrowser userscripts linked"
else
  warn "elsummariz00r scripts not found — check the repo structure"
fi

# ═══════════════════════════════════════════════════════════
# 22. done
# ═══════════════════════════════════════════════════════════

echo ""
echo "  ╔═══════════════════════════════════════╗"
if $DRY_RUN; then
echo "  ║     dry run complete — no changes     ║"
else
echo "  ║          setup complete               ║"
fi
echo "  ╚═══════════════════════════════════════╝"
echo ""
if ! $DRY_RUN; then
  echo "  next steps:"
  echo "    1. restart your terminal (or: source ~/.zshrc)"
  echo "    2. open nvim once to auto-install plugins"
  echo "    3. generate ssh keys: ssh-keygen -t ed25519"
  echo "    4. set up git lfs: git lfs install"
  echo ""
  if [ -d "$BACKUP_DIR" ]; then
    echo "  backups saved to: $BACKUP_DIR"
    echo ""
  fi
fi
