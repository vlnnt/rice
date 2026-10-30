#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
BACKUP_DIR="$STATE_DIR/rice/backups/$(date +%Y%m%d-%H%M%S)-$$"

INSTALL_PACKAGES=false
INSTALL_CONFIGS=true
INSTALL_SYSTEM_BIN=false
UPDATE_SYSTEM=false
DRY_RUN=false

usage() {
    cat <<'HELP'
Usage: bash install.sh [OPTIONS]

  --packages       Install missing packages and configurations
  --packages-only  Install missing packages, without configurations
  --update         Perform a full system upgrade (implies --packages)
  --configs-only   Install only configurations (default)
  --system-bin     Also install vidthumb and pdfthumb to /usr/local/bin
  --dry-run        Show planned actions without modifying anything
  -h, --help       Show this help

Installing missing packages may require a full pacman -Syu upgrade.
HELP
}

for arg in "$@"; do
    case "$arg" in
        --packages) INSTALL_PACKAGES=true ;;
        --packages-only) INSTALL_PACKAGES=true; INSTALL_CONFIGS=false ;;
        --update) INSTALL_PACKAGES=true; UPDATE_SYSTEM=true ;;
        --configs-only) INSTALL_PACKAGES=false; INSTALL_CONFIGS=true; UPDATE_SYSTEM=false ;;
        --system-bin) INSTALL_SYSTEM_BIN=true ;;
        --dry-run) DRY_RUN=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
    esac
done

if (( EUID == 0 )); then
    echo "Error: Run this script as a regular user, not root." >&2
    exit 1
fi

if [[ ! -r /etc/os-release ]]; then
    echo "Error: Cannot detect Linux distribution." >&2
    exit 1
fi

source /etc/os-release
case "${ID:-}" in
    arch|artix) echo "Distribution: ${PRETTY_NAME:-$ID}" ;;
    *) echo "Error: Only Arch Linux and Artix Linux are supported." >&2; exit 1 ;;
esac

command -v pacman >/dev/null 2>&1 || {
    echo "Error: pacman is not available." >&2
    exit 1
}

as_root() {
    if command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    elif command -v doas >/dev/null 2>&1; then
        doas "$@"
    else
        echo "Error: sudo or doas is required for this operation." >&2
        return 1
    fi
}

configs=(
    hypr
    kitty
    lf
    neofetch
    nvim
    ohmyposh
    swaync
    waybar
    wlogout
    wofi
    zathura
)

[[ -d "$REPO_DIR/cava" ]] && configs+=(cava)

install_packages() {
    local -a packages=(
        hyprland 
        hypridle 
        hyprlock 
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk 
        xorg-xwayland
        kitty 
        lf 
        neovim 
        thunar 
        zathura 
        zathura-pdf-mupdf
        swaync
        wofi 
        wlogout 
        cava
        wl-clipboard 
        cliphist
        pipewire 
        pipewire-pulse 
        wireplumber 
        pavucontrol
        network-manager-applet 
        udiskie
        grim 
        slurp 
        brightnessctl 
        playerctl
        ffmpegthumbnailer 
        poppler 
        imagemagick
        zsh 
        fzf 
        zoxide 
        git 
        rsync
        ttf-jetbrains-mono-nerd 
        otf-font-awesome
        qt6ct 
        qt6-wayland
        awww
    )

    local -a optional=(
        neofetch 
        oh-my-posh 
        pistol 
        xwaylandvideobridge
    )

    if ! pacman -Qq waybar-git >/dev/null 2>&1; then
        packages+=(waybar)
    fi

    local -a missing=() installable=() unavailable=()
    local package
    for package in "${packages[@]}" "${optional[@]}"; do
        if ! pacman -Qq "$package" >/dev/null 2>&1; then
            missing+=("$package")
        fi
    done

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Packages not currently installed:"
        if ((${#missing[@]})); then
            printf '  %s\n' "${missing[@]}"
        else
            echo "  (none)"
        fi

        if ((${#missing[@]})) || [[ "$UPDATE_SYSTEM" == true ]]; then
            echo "[DRY RUN] Package installation uses a full pacman -Syu upgrade."
        fi

        return 0
    fi

    if [[ "$UPDATE_SYSTEM" == false ]]; then
        local -a currently_available=()
        for package in "${missing[@]}"; do
            if pacman -Si "$package" >/dev/null 2>&1; then
                currently_available+=("$package")
            fi
        done

        if ((${#currently_available[@]} == 0)); then
            echo "No missing packages found in current repository metadata. Skipping pacman."
            if ((${#missing[@]})); then
                echo "Unavailable or AUR-only packages: ${missing[*]}"
                echo "Use --update to refresh the repositories if this looks wrong."
            fi
            return 0
        fi
    fi

    echo "Updating the system with pacman -Syu before package installation..."
    echo "Review any pacman prompts carefully."
    as_root pacman -Syu

    for package in "${missing[@]}"; do
        if pacman -Qq "$package" >/dev/null 2>&1; then
            continue
        fi
        if pacman -Si "$package" >/dev/null 2>&1; then
            installable+=("$package")
        else
            unavailable+=("$package")
        fi
    done

    if ((${#installable[@]})); then
        as_root pacman -S --needed -- "${installable[@]}"
    fi

    if ((${#unavailable[@]})); then
        echo "Not found in your enabled pacman repositories (not installed):" >&2
        printf '  %s\n' "${unavailable[@]}" >&2
        echo "Install required AUR/third-party programs separately." >&2
    fi
}

install_config() {
    local name="$1"
    local source="$REPO_DIR/$name/"
    local target="$CONFIG_DIR/$name"

    if [[ ! -d "$source" ]]; then
        echo "Error: Missing repository directory: $source" >&2
        return 1
    fi

    if [[ -L "$target" ]]; then
        echo "Error: Refusing to overwrite a symlink: $target" >&2
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] $source -> $target/"
        [[ -e "$target" ]] && echo "[DRY RUN] Backup: $target"
        return 0
    fi

    if [[ -e "$target" ]]; then
        mkdir -p -- "$BACKUP_DIR/config"
        cp -a -- "$target" "$BACKUP_DIR/config/$name"
        echo "Backed up: $target"
    fi

    mkdir -p -- "$target"
    rsync -a -- "$source" "$target/"
    echo "Installed: $target"
}

install_config_file() {
    local name="$1"
    local file="$2"

    local source="$REPO_DIR/$name/$file"
    local target="$CONFIG_DIR/$name/$file"

    if [[ ! -f "$source" ]]; then
        echo "Error: Missing repository file: $source" >&2
        return 1
    fi

    if [[ -L "$target" ]]; then
        echo "Error: Refusing to overwrite a symlink: $target" >&2
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] $source -> $target"
        [[ -e "$target" ]] && echo "[DRY RUN] Backup: $target"
        return 0
    fi

    if [[ -e "$target" ]]; then
        mkdir -p -- "$BACKUP_DIR/config/$name"
        cp -a -- "$target" "$BACKUP_DIR/config/$name/$file"

        echo "Backed up: $target"
    fi

    mkdir -p -- "$(dirname -- "$target")"
    rsync -a -- "$source" "$target"

    echo "Installed: $target"
}

install_zshrc() {
    local source="$REPO_DIR/.zshrc"
    local target="$HOME/.zshrc"

    if [[ ! -f "$source" ]]; then
        echo "Skipping .zshrc: not present in repository."
        return 0
    fi

    if [[ -L "$target" ]]; then
        echo "Error: Refusing to overwrite a symlink: $target" >&2
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] $source -> $target"
        [[ -e "$target" ]] && echo "[DRY RUN] Backup: $target"
        return 0
    fi

    if [[ -e "$target" ]]; then
        mkdir -p -- "$BACKUP_DIR/home"
        cp -a -- "$target" "$BACKUP_DIR/home/.zshrc"
        echo "Backed up: $target"
    fi

    rsync -a -- "$source" "$target"
    echo "Installed: $target"
}

install_system_bin() {
    local name="$1"
    local source="$REPO_DIR/local/bin/$name"
    local target="/usr/local/bin/$name"

    if [[ ! -f "$source" ]]; then
        echo "Error: Missing repository file: $source" >&2
        return 1
    fi

    if [[ -L "$target" ]]; then
        echo "Error: Refusing to overwrite a symlink: $target" >&2
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] $source -> $target (executable)"
        [[ -e "$target" ]] && echo "[DRY RUN] Backup: $target"
        return 0
    fi

    if [[ -e "$target" ]]; then
        mkdir -p -- "$BACKUP_DIR/local/bin"
        cp -a -- "$target" "$BACKUP_DIR/local/bin/$name"
        echo "Backed up: $target"
    fi

    as_root install -Dm755 -- "$source" "$target"
    echo "Installed: $target"
}

if [[ "$INSTALL_PACKAGES" == true ]]; then
    install_packages
fi

if [[ "$INSTALL_CONFIGS" == true ]]; then
    if [[ "$DRY_RUN" == false ]]; then
        command -v rsync >/dev/null 2>&1 || {
            echo "Error: rsync is missing. Install rsync or use --packages." >&2
            exit 1
        }
    fi
    
    for name in "${configs[@]}"; do
        install_config "$name"
    done

    install_config_file wallpapers artix_wallpaper.png
    install_zshrc
fi

if [[ "$INSTALL_SYSTEM_BIN" == true ]]; then
    install_system_bin vidthumb
    install_system_bin pdfthumb
fi

echo
if [[ "$DRY_RUN" == true ]]; then
    echo "Rice dry run completed; nothing was changed."
else
    echo "Rice installation completed."
fi

if [[ "$DRY_RUN" == false && -d "$BACKUP_DIR" ]]; then
    echo "Backups: $BACKUP_DIR"
fi

if [[ "$INSTALL_PACKAGES" == true && "$DRY_RUN" == false ]]; then
    echo "Note: waybar-git and waybar-updates (AUR) are not installed automatically."
    echo "Note: awww does not provide the old swww command; update old calls if present."
fi