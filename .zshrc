setopt no_beep

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$HOME/go/bin:$PATH"

export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

typeset -U path

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

if [[ ! -e "$ZINIT_HOME" ]] && (( $+commands[git] )); then
    mkdir -p -- "${ZINIT_HOME:h}"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
    source "$ZINIT_HOME/zinit.zsh"
    zinit light zsh-users/zsh-completions
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

autoload -Uz compinit
compinit

if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
    zinit cdreplay -q
fi

HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

alias ls='ls --color'

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

if (( $+commands[fzf] )); then
    eval "$(fzf --zsh)"
fi

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
    zinit light Aloxaf/fzf-tab
    zinit light zsh-users/zsh-autosuggestions
fi

if (( $+commands[oh-my-posh] )) &&
   [[ -f "$HOME/.config/ohmyposh/zen.toml" ]]; then
    eval "$(oh-my-posh init zsh --config "$HOME/.config/ohmyposh/zen.toml")"
fi

if [[ -f "$ZINIT_HOME/zinit.zsh" ]]; then
    zinit light zsh-users/zsh-syntax-highlighting
fi

if [[ -z "${WAYLAND_DISPLAY:-}" &&
      -z "${DISPLAY:-}" &&
      -z "${SSH_TTY:-}" &&
      "${XDG_VTNR:-}" == "1" ]] &&
   (( $+commands[start-hyprland] )) &&
   (( $+commands[dbus-run-session] )); then
    exec dbus-run-session start-hyprland
fi
