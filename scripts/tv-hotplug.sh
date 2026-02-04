#!/bin/bash
# TV Hotplug Monitor for Hyprland
# Monitors HDMI-A-1 (Samsung TV) connection status

TV_OUTPUT="HDMI-A-1"
TV_DRM_PATH="/sys/class/drm/card1-HDMI-A-1/status"
STATE_FILE="/tmp/hypr-tv-state"
POLL_INTERVAL=2  # seconds between polls if inotify not available

# Get current connection status from kernel
get_drm_status() {
    cat "$TV_DRM_PATH" 2>/dev/null || echo "disconnected"
}

# Get current hyprland state for TV
get_hypr_state() {
    hyprctl monitors -j | jq -r ".[] | select(.name == \"$TV_OUTPUT\") | .disabled" 2>/dev/null
}

# Enable TV output
enable_tv() {
    echo "Enabling TV output..."
    hyprctl keyword monitor "$TV_OUTPUT,1920x1080@60,5120x0,auto"
    echo "enabled" > "$STATE_FILE"
    notify-send -t 3000 "📺 TV" "Display enabled" -i video-display 2>/dev/null || true
}

# Disable TV output
disable_tv() {
    echo "Disabling TV output..."
    # Move TV workspace to main monitor first
    hyprctl dispatch moveworkspacetomonitor "10 DP-2" 2>/dev/null
    hyprctl keyword monitor "$TV_OUTPUT,disable"
    echo "disabled" > "$STATE_FILE"
    notify-send -t 3000 "TV" "Display disabled" -i video-display 2>/dev/null || true
}

# Toggle TV state
toggle_tv() {
    local current_state=$(cat "$STATE_FILE" 2>/dev/null || echo "enabled")
    if [[ "$current_state" == "enabled" ]]; then
        disable_tv
    else
        enable_tv
    fi
}

# Monitor for hotplug events
monitor_hotplug() {
    echo "Starting TV hotplug monitor..."
    local last_status=$(get_drm_status)
    echo "Initial status: $last_status"

    # Initialize state file
    if [[ "$last_status" == "connected" ]]; then
        echo "enabled" > "$STATE_FILE"
    else
        echo "disabled" > "$STATE_FILE"
        disable_tv
    fi

    # Check if inotifywait is available for efficient monitoring
    if command -v inotifywait &>/dev/null; then
        echo "Using inotify for efficient event-based monitoring"
        while true; do
            inotifywait -q -e modify "$TV_DRM_PATH" 2>/dev/null
            sleep 0.5  # Debounce

            local new_status=$(get_drm_status)
            if [[ "$new_status" != "$last_status" ]]; then
                echo "TV status changed: $last_status -> $new_status"
                if [[ "$new_status" == "connected" ]]; then
                    enable_tv
                else
                    disable_tv
                fi
                last_status="$new_status"
            fi
        done
    else
        echo "inotifywait not found, falling back to polling every ${POLL_INTERVAL}s"
        echo "Install inotify-tools for more efficient monitoring: sudo pacman -S inotify-tools"
        while true; do
            sleep "$POLL_INTERVAL"
            local new_status=$(get_drm_status)
            if [[ "$new_status" != "$last_status" ]]; then
                echo "TV status changed: $last_status -> $new_status"
                if [[ "$new_status" == "connected" ]]; then
                    enable_tv
                else
                    disable_tv
                fi
                last_status="$new_status"
            fi
        done
    fi
}

# Main command handling
case "${1:-}" in
    enable)
        enable_tv
        ;;
    disable)
        disable_tv
        ;;
    toggle)
        toggle_tv
        ;;
    status)
        echo "DRM status: $(get_drm_status)"
        echo "State file: $(cat "$STATE_FILE" 2>/dev/null || echo "unknown")"
        echo "Hyprland disabled: $(get_hypr_state)"
        ;;
    monitor)
        monitor_hotplug
        ;;
    *)
        echo "Usage: $0 {enable|disable|toggle|status|monitor}"
        echo ""
        echo "Commands:"
        echo "  enable  - Enable TV output"
        echo "  disable - Disable TV output and move windows"
        echo "  toggle  - Toggle TV state"
        echo "  status  - Show current TV status"
        echo "  monitor - Run continuous hotplug monitoring"
        exit 1
        ;;
esac
