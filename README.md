# rice
My personal Hyprland-based dotfiles.

## Installation

Supports Arch Linux and Artix Linux.

Full installation (packages and configs):
```bash
bash install.sh --packages
```

Only configs (default):
```bash
bash install.sh
```

Only packages:
```bash
bash install.sh --packages-only
```

Full installation with system upgrade:
```bash
bash install.sh --update
```

System binaries (`vidthumb` and `pdfthumb`):
```bash
bash install.sh --system-bin
```

Configs and system binaries without package installation:
```bash
bash install.sh --configs-only --system-bin
```

Preview installation without making changes:
```bash
bash install.sh --dry-run
```

Preview full installation:
```bash
bash install.sh --packages --dry-run
```

Show all available options:
```bash
bash install.sh --help
```