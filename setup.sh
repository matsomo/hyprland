#!/bin/bash

# HyprPanel Configuration Setup Script
# This script loads environment variables and updates the config.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
CONFIG_FILE="$SCRIPT_DIR/hyprpanel/config.json"

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found!"
    echo "Please copy .env.example to .env and fill in your API key:"
    echo "  cp $SCRIPT_DIR/.env.example $SCRIPT_DIR/.env"
    exit 1
fi

# Load environment variables
source "$ENV_FILE"

# Check if API key is set
if [ -z "$WEATHER_API_KEY" ] || [ "$WEATHER_API_KEY" = "YOUR_WEATHER_API_KEY_HERE" ]; then
    echo "Error: WEATHER_API_KEY not set in .env file!"
    echo "Please edit $ENV_FILE and add your weather API key."
    exit 1
fi

# Update config.json with the API key
if [ -f "$CONFIG_FILE" ]; then
    # Create a backup
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
    
    # Replace the API key using jq (if available) or sed
    if command -v jq &> /dev/null; then
        # Use jq for safe JSON manipulation
        jq --arg key "$WEATHER_API_KEY" '.["menus.clock.weather.key"] = $key' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "✓ API key updated successfully using jq"
    else
        # Fallback to sed
        sed -i "s|\"menus.clock.weather.key\": \".*\"|\"menus.clock.weather.key\": \"$WEATHER_API_KEY\"|" "$CONFIG_FILE"
        echo "✓ API key updated successfully using sed"
    fi
    
    echo "✓ Configuration updated: $CONFIG_FILE"
    echo "✓ Backup saved: $CONFIG_FILE.backup"
else
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi
