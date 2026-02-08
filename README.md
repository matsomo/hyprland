# Hyprland Configuration

Hyprland setup including hyprpanel, hyprlock, and hyprpaper configurations.

## Structure

- `conf/` - Main Hyprland configuration files
  - `hyprland.conf` - Core Hyprland window manager config
  - `hyprlock.conf` - Lock screen configuration
  - `hyprpaper.conf` - Wallpaper daemon configuration
- `hyprpanel/` - HyprPanel config and themes
  - `config.json` - Active HyprPanel configuration
  - `themes/` - SCSS theme files (petrikeys, tokyo-night)
- `scripts/` - Helper scripts for status information
  - Battery, network, layout, and media status scripts

## Installation

```bash
# Clone the repository
git clone https://github.com/matsomo/hyprland.git ~/.config/hyprland

# Create symlinks
mkdir -p ~/.config/hypr
ln -s ~/.config/hyprland/conf/hyprland.conf ~/.config/hypr/hyprland.conf
ln -s ~/.config/hyprland/conf/hyprlock.conf ~/.config/hypr/hyprlock.conf
ln -s ~/.config/hyprland/conf/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
ln -s ~/.config/hyprland/scripts ~/.config/hypr/scripts
ln -s ~/.config/hyprland/hyprpanel ~/.config/hyprpanel

# Configure weather API key (optional)
cd ~/.config/hyprland
cp .env.example .env
# Edit .env and add your weather API key from https://www.weatherapi.com/
# Then run the setup script to update the configuration
./setup.sh
```

## Color Scheme

Using a custom color palette inspired by [Petrikeys](https://www.instagram.com/yooj.key/?hl=en) keycaps:
- Background: `#1B2A49` (Navy Blue)
- Accent: `#008EDB` (Bright Blue)
- Highlight: `#56C4E1` (Sky Blue)
- Success: `#7EE2B8` (Mint Green)

*Theme inspired by the Petrikeys keycap set designed by [@yooj.key](https://www.instagram.com/yooj.key/?hl=en)*

## Requirements

### Core
- Hyprland
- HyprPanel
- Hyprlock
- swww (wallpaper daemon)

### Hyprlock dependencies
- **SF Pro fonts** (`otf-san-francisco` or similar from AUR) - used by all lock screen labels
- **playerctl** - media status on lock screen (`song-status` script)
- **bat** - keyboard layout detection (`layout-status` script)
- **NetworkManager** - network status icon (`network-status` script)
- **python** - wifi signal strength (`network-status` script)

### Install on Arch

```bash
sudo pacman -S playerctl bat networkmanager python

# SF Pro fonts (AUR)
yay -S otf-san-francisco
```

### Scripts symlink

The hyprlock config references scripts at `~/.config/Scripts/`. Create a symlink:

```bash
ln -s ~/.config/hyprland/scripts ~/.config/Scripts
```

## Customization

Before using, update the following for your system:

- **Monitor name** - all widgets in `hyprlock.conf` are pinned to `monitor = DP-2`. Find yours with `hyprctl monitors` and replace accordingly.
- **Username** - "matsa" is hardcoded in `hyprlock.conf`
- **Wallpaper** - `~/Images/microbes_dark.jpg` must exist (also referenced in `hyprpaper.conf`)
- **Profile picture** - `~/Pictures/fullpfp.png` must exist
- **Battery script** - reads from `/sys/class/power_supply/BAT1/`, which may differ on your hardware or not exist on desktops

## Notes

After system updates, you may need to reload Hyprland configuration:
```bash
hyprctl reload
```

### Known Issues
- The `network-status` script references `~/.config/Scripts/wifi-conn-strength` which is not included in this repo. The script will fallback to showing ethernet icon if this file is missing.
