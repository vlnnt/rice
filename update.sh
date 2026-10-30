#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
DRY_RUN=false

case "${1:-}" in
    "") ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help)
        echo "Usage: bash update.sh [--dry-run]"
        exit 0
        ;;
    *)
        echo "Usage: bash update.sh [--dry-run]" >&2
        exit 2
        ;;
esac

command -v rsync >/dev/null 2>&1 || {
    echo "Error: rsync is not installed." >&2
    exit 1
}

sync_config() {
    local name="$1"
    local source="$CONFIG_DIR/$name/"
    local target="$REPO_DIR/$name/"

    if [[ ! -d "$source" ]]; then
        echo "Error: Missing config directory: $source" >&2
        return 1
    fi

    if [[ -L "$REPO_DIR/$name" ]]; then
        echo "Error: Refusing to write through repository symlink: $target" >&2
        return 1
    fi

    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p -- "$target"
    fi

    local -a args=(-av --delete)
    [[ "$DRY_RUN" == true ]] && args+=(-n)

    rsync "${args[@]}" -- "$source" "$target"

    echo "Synced: $name"
}

sync_config_files() {
    local name="$1"
    shift

    local source="$CONFIG_DIR/$name"
    local target="$REPO_DIR/$name"
    local file

    for file in "$@"; do
        if [[ ! -f "$source/$file" ]]; then
            echo "Error: Missing file: $source/$file" >&2
            return 1
        fi
    done

    if [[ -L "$target" ]]; then
        echo "Error: Refusing to write through repository symlink: $target" >&2
        return 1
    fi

    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p -- "$target"
    fi

    local -a args=(-av)
    [[ "$DRY_RUN" == true ]] && args+=(-n)

    for file in "$@"; do
        rsync "${args[@]}" -- "$source/$file" "$target/"
    done

    echo "Synced: $name (selected files)"
}

sync_system_bin() {
    local name="$1"
    local source="/usr/local/bin/$name"
    local target="$REPO_DIR/local/bin/"

    if [[ ! -f "$source" ]]; then
        echo "Warning: $source not found; keeping the repository copy." >&2
        return 0
    fi

    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p -- "$target"
    fi

    local -a args=(-av)
    [[ "$DRY_RUN" == true ]] && args+=(-n)

    rsync "${args[@]}" -- "$source" "$target"

    echo "Synced: local/bin/$name"
}

configs=(
    hypr
    lf
    neofetch
    nvim
    swaync
    waybar
    wlogout
    wofi
    zathura
)

for name in "${configs[@]}"; do
    sync_config "$name"
done

sync_config_files kitty \
    kitty.conf \
    colors-kitty.conf

sync_config_files ohmyposh zen.toml

sync_config_files wallpapers artix_wallpaper.png

if [[ -d "$CONFIG_DIR/cava" ]]; then
    sync_config cava
else
    echo "Skipping cava: no local configuration directory."
fi

if [[ -f "$HOME/.zshrc" ]]; then
    local_args=(-av)
    [[ "$DRY_RUN" == true ]] && local_args+=(-n)

    rsync "${local_args[@]}" -- \
        "$HOME/.zshrc" \
        "$REPO_DIR/.zshrc"

    echo "Synced: .zshrc"
else
    echo "Warning: ~/.zshrc not found; keeping the repository copy." >&2
fi

sync_system_bin vidthumb
sync_system_bin pdfthumb

echo

if [[ "$DRY_RUN" == true ]]; then
    echo "Rice dry run completed; nothing was changed."
else
    echo "Rice update completed."
fi

echo "Review changes with: git -C \"$REPO_DIR\" diff --stat"