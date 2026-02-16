# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
export EDITOR=nvim

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

PATH=~/.console-ninja/.bin:$PATH
PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Automatically load nvm node version
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
export PATH="$HOME/.fuelup/bin:$PATH"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH=$HOME/.local/bin:$PATH

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# Claude Code session-end sound wrapper
function claude() {
  command claude "$@"
  local exit_code=$?
  afplay $HOME/Library/Sounds/session-end.wav
  return $exit_code
}


alias qb="$HOME/Library/Python/3.14/bin/qutebrowser"
export PYTHONPATH="/opt/homebrew/lib/python3.14/site-packages:$PYTHONPATH"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# --- Apple Music Terminal Controls ---
# Dashboard & Basic Controls
alias ams="am-search"

# Unified 'am' Controller Wrapper
am() {
    case "$1" in
        shuffle)
            osascript -e 'tell application "Music" to set shuffle enabled to (not shuffle enabled)' && \
            osascript -e 'tell application "Music" to get shuffle enabled' | sed 's/true/Shuffle: ON/;s/false/Shuffle: OFF/'
            ;;
        repeat)
            osascript -e 'tell application "Music"
                if song repeat is off then
                    set song repeat to all
                    return "Repeat: ALL"
                else if song repeat is all then
                    set song repeat to one
                    return "Repeat: ONE"
                else
                    set song repeat to off
                    return "Repeat: OFF"
                end if
            end tell'
            ;;
        fav)
            osascript -e 'tell application "Music"
                try
                    set favorited of current track to true
                    return "Favorited: " & name of current track & " ❤️"
                on error
                    return "Error: No track playing or unable to favorite."
                end try
            end tell'
            ;;
        play-fav)
            echo "Playing your Favorite Songs... ❤️"
            osascript -e 'tell application "Music" to play playlist "Favourite Songs"'
            ;;
        list)
            # 1. Try AppleScript for Library Playlists
            local as_output=$(osascript -e 'tell application "Music"
                try
                    set plName to name of current playlist
                    set songList to name of every track of current playlist
                    set artistList to artist of every track of current playlist
                    set output to "Playlist: " & plName & "\n"
                    repeat with i from 1 to count of songList
                        set output to output & i & ". " & item i of songList & " - " & item i of artistList & "\n"
                    end repeat
                    return output
                on error
                    return "UI_ERROR"
                end try
            end tell')

            if [[ "$as_output" != "UI_ERROR" ]]; then
                echo "$as_output"
            else
                # 2. Fallback to Engine for Global Playlists
                local pl_id=$(cat ~/.cache/am_current_playlist_id 2>/dev/null)
                local pl_name=$(cat ~/.cache/am_current_playlist_name 2>/dev/null)
                if [[ -n "$pl_id" ]]; then
                    echo "Playlist: $pl_name (Global Store)"
                    $HOME/Documents/music/Yatoro-Fire/.build/release/yatoro tracks "$pl_id" | jq -r 'to_entries | .[] | "\(.key + 1). \(.value.title) - \(.value.artist)"'
                else
                    echo "Error: No active playlist or Music app not playing."
                fi
            fi
            ;;
        jump)
            if [[ -z "$2" ]]; then
                echo "Usage: am jump <number>"
                return 1
            fi
            # Try AppleScript Jump
            local jump_res=$(osascript -e "tell application \"Music\"
                try
                    play track $2 of current playlist
                    return \"SUCCESS\"
                on error
                    return \"FAIL\"
                end try
            end tell")
            
            if [[ "$jump_res" == "SUCCESS" ]]; then
                echo "Jumping to track $2..."
            else
                # Global Playlist Jump: Re-inject specific song
                local pl_id=$(cat ~/.cache/am_current_playlist_id 2>/dev/null)
                if [[ -n "$pl_id" ]]; then
                    # This logic could be expanded to fetch song IDs, but for now we report limitation
                    echo "Note: 'am jump' is limited to Library playlists. Use 'am next' for global queues."
                else
                    echo "Error: Invalid track number or no active playlist."
                fi
            fi
            ;;
        *)
            # Pass all other commands to the actual 'am' Rust binary
            $HOME/.local/bin/am "$@"
            ;;
    esac
}

# Search and Play ANY song from the global Apple Music catalog (Fire Setup)
am-search() {
    local query="$*"
    if [[ -z "$query" ]]; then
        echo "Usage: ams <song or playlist>"
        return 1
    fi

    # 1. Search Global Catalog using our 'Fire' binary
    local results=$($HOME/Documents/music/Yatoro-Fire/.build/release/yatoro search "$query")
    
    if [[ "$results" == Error* ]] || [[ -z "$results" ]] || [[ "$results" == "[]" ]]; then
        echo "Engine Error or No results found for '$query'."
        return 1
    fi

    # 2. Display results
    echo "Top results for '$query':"
    echo "$results" | jq -r '.[] | "\(.title) by \(.artist // .curator) [\(.type)]"' | nl
    
    echo -n "Play which number? (q to quit): "
    read choice
    
    if [[ "$choice" == "q" || -z "$choice" ]]; then
        return 0
    fi

    # 3. Get the details
    local song_data=$(echo "$results" | jq -r ".[$((choice-1))]")
    local track_id=$(echo "$song_data" | jq -r ".id")
    local title=$(echo "$song_data" | jq -r ".title")
    local type=$(echo "$song_data" | jq -r ".type")
    
    if [[ "$track_id" == "null" ]]; then
        echo "Invalid selection."
        return 1
    fi

    # Save playlist state for 'am list'
    if [[ "$type" == *"playlist"* ]]; then
        echo "$track_id" > ~/.cache/am_current_playlist_id
        echo "$title" > ~/.cache/am_current_playlist_name
    else
        # Clear playlist state if playing a single song
        rm ~/.cache/am_current_playlist_id 2>/dev/null
    fi

    if [[ "$type" == "playlist" || "$type" == "song" ]]; then
        echo "Injecting Global Item into Native Queue: $title..."
        bridge-player "$track_id"
    elif [[ "$type" == "library-playlist" ]]; then
        echo "Playing Library Playlist: $title..."
        osascript -e "tell application \"Music\" to play playlist \"$title\""
    elif [[ "$type" == "library-song" ]]; then
        echo "Playing Library Song: $title..."
        # Find and play by exact name which is more reliable for Library items
        osascript -e "tell application \"Music\" to play track \"$title\""
    fi
}


# Search and Play ANY playlist from the global Apple Music catalog
am-playlist() {
    local query="$*"
    if [[ -z "$query" ]]; then
        echo "Usage: am-playlist <playlist name>"
        return 1
    fi

    # Use the verified 'Fire' binary
    local results=$($HOME/Documents/music/Yatoro-Fire/.build/release/yatoro search "$query")
    
    if [[ "$results" == Error* ]] || [[ -z "$results" ]] || [[ "$results" == "[]" ]]; then
        echo "No playlists found for '$query'."
        return 1
    fi

    # Filter for playlists only
    local pl_results=$(echo "$results" | jq '[.[] | select(.type == "playlist")]')
    
    if [[ $(echo "$pl_results" | jq 'length') -eq 0 ]]; then
        echo "No playlists found for '$query'."
        return 1
    fi

    echo "Top playlists for '$query':"
    echo "$pl_results" | jq -r '.[] | "\(.title) by \(.curator)"' | nl
    
    echo -n "Play which number? (q to quit): "
    read choice
    
    if [[ "$choice" == "q" || -z "$choice" ]]; then
        return 0
    fi

    local playlist_id=$(echo "$pl_results" | jq -r ".[$((choice-1))].id")
    local title=$(echo "$pl_results" | jq -r ".[$((choice-1))].title")
    
    if [[ "$playlist_id" == "null" ]]; then
        echo "Invalid selection."
        return 1
    fi

    echo "Opening Playlist: $title..."
    open "music://music.apple.com/playlist/$playlist_id?action=play"
}


