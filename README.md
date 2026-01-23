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
git clone https://github.com/yourusername/hyprland.git ~/.config/hyprland

# Create symlinks
mkdir -p ~/.config/hypr
ln -s ~/.config/hyprland/conf/hyprland.conf ~/.config/hypr/hyprland.conf
ln -s ~/.config/hyprland/conf/hyprlock.conf ~/.config/hypr/hyprlock.conf
ln -s ~/.config/hyprland/conf/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
ln -s ~/.config/hyprland/scripts ~/.config/hypr/scripts
ln -s ~/.config/hyprland/hyprpanel ~/.config/hyprpanel

# Configure weather API key (optional)
# Get a free API key from https://www.weatherapi.com/
# Edit hyprpanel/config.json and replace YOUR_WEATHER_API_KEY_HERE with your key
```

## Color Scheme

Using a custom color palette inspired by [Petrikeys](https://www.instagram.com/yooj.key/?hl=en) keycaps:
- Background: `#1B2A49` (Navy Blue)
- Accent: `#008EDB` (Bright Blue)
- Highlight: `#56C4E1` (Sky Blue)
- Success: `#7EE2B8` (Mint Green)

*Theme inspired by the Petrikeys keycap set designed by [@yooj.key](https://www.instagram.com/yooj.key/?hl=en)*

## Requirements

- Hyprland
- HyprPanel
- Hyprlock
- Hyprpaper
- NetworkManager (for network icon)
- Wezterm (terminal)

## Notes

After system updates, you may need to reload Hyprland configuration:
```bash
hyprctl reload
```

### Known Issues
- The `network-status` script references `~/.config/Scripts/wifi-conn-strength` which is not included in this repo. The script will fallback to showing ethernet icon if this file is missing.
- Personal paths in `hyprlock.conf` and `hyprpaper.conf` may need to be adjusted for your system (wallpaper paths, profile picture, etc.)



