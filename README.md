# Hyprland Configuration

My personal Hyprland setup including hyprpanel, hyprlock, and hyprpaper configurations.

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
git clone https://github.com/yourusername/hyprland.git ~/hyprland

# Create symlinks
mkdir -p ~/.config/hypr
ln -s ~/hyprland/conf/hyprland.conf ~/.config/hypr/hyprland.conf
ln -s ~/hyprland/conf/hyprlock.conf ~/.config/hypr/hyprlock.conf
ln -s ~/hyprland/conf/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
ln -s ~/hyprland/scripts ~/.config/hypr/scripts
ln -s ~/hyprland/hyprpanel ~/.config/hyprpanel
```

## Color Scheme

Using a custom Petrikeys-inspired color palette:
- Background: `#1B2A49` (Navy Blue)
- Accent: `#008EDB` (Bright Blue)
- Highlight: `#56C4E1` (Sky Blue)
- Success: `#7EE2B8` (Mint Green)

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
