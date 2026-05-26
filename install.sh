#!/bin/bash

# MenuForge v1.1.0-Stable Installer
# Developed by SahooShuvranshu & Crystal Studio Labs
# Contact: connect.crystalstudio@gmail.com

# --- Branding & Colors ---
PRIMARY="#00D7FF" # Cyan/Blue
SECONDARY="#FFFFFF" # White (No Pink)

# --- Initial Setup (Ensure Gum is available for TUI) ---
if ! command -v gum &> /dev/null; then
    echo "Installing initial TUI dependencies..."
    sudo pacman -S --needed --noconfirm gum
fi

banner() {
    clear
    # High-Quality MenuForge Block Art
    echo ""
    gum style --foreground "$PRIMARY" --align center --width 60 "
  ███╗   ███╗███████╗███╗   ██╗██╗   ██╗
  ████╗ ████║██╔════╝████╗  ██║██║   ██║
  ██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
  ██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
  ██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
  ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ 
  ███████╗ ██████╗ ██████╗  ██████╗ ███████╗
  ██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝
  █████╗  ██║   ██║██████╔╝██║  ███╗█████╗  
  ██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝  
  ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗
  ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
"
    gum style \
        --foreground "$PRIMARY" --border-foreground "$SECONDARY" --border rounded \
        --align center --width 60 --margin "0 2" --padding "1 1" \
        "MENUFORGE INSTALLER" \
        "v1.1.0-Stable | Crystal Studio Labs"
    echo ""
}

# --- 1. Welcome ---
banner
gum format "
### WELCOME
This installer will deploy **MenuForge v1.1.0-Stable** to your system.

**Deployment Steps:**
1. Install system dependencies (GameMode, MangoHud, etc.)
2. Deploy binaries and official assets (Icons)
3. Generate desktop launcher for menu integration

*Press [ENTER] to begin installation...*
"
gum input --placeholder "" --password &> /dev/null

# --- 2. Dependencies ---
banner
gum style --foreground "$PRIMARY" " ❯ Step 1: Installing System Dependencies "
echo "This may require your sudo password..."

# Run pacman in a spin
gum spin --spinner dot --title "Syncing repositories and installing packages..." -- \
    sudo pacman -S --needed --noconfirm gamemode mangohud gamescope wine imagemagick

# --- 3. File Deployment ---
banner
gum style --foreground "$PRIMARY" " ❯ Step 2: Deploying Binaries & Assets "

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/applications"
mkdir -p "$HOME/.local/share/icons"

# Copy binary
if [ -f "menuforge" ]; then
    cp menuforge "$HOME/.local/bin/menuforge"
    chmod +x "$HOME/.local/bin/menuforge"
    gum style --foreground 10 "  [✔] Binary installed to ~/.local/bin/menuforge"
else
    gum style --foreground 1 "  [✘] Error: 'menuforge' script not found."
    exit 1
fi

# Copy dependency installer
if [ -f "menuforge-dep-installer" ]; then
    cp menuforge-dep-installer "$HOME/.local/bin/menuforge-dep-installer"
    chmod +x "$HOME/.local/bin/menuforge-dep-installer"
    gum style --foreground 10 "  [✔] Dep-Installer installed to ~/.local/bin/"
fi

# Copy official icon from assets
if [ -f "assets/logo.png" ]; then
    cp assets/logo.png "$HOME/.local/share/icons/menuforge.png"
    ICON_PATH="$HOME/.local/share/icons/menuforge.png"
    gum style --foreground 10 "  [✔] Official icon installed from assets/"
elif [ -f "logo.png" ]; then
    cp logo.png "$HOME/.local/share/icons/menuforge.png"
    ICON_PATH="$HOME/.local/share/icons/menuforge.png"
    gum style --foreground 10 "  [✔] Official icon installed from root/"
else
    ICON_PATH="terminal"
    gum style --foreground "$SECONDARY" "  [!] Warning: Official logo not found. Falling back to terminal icon."
fi

# --- 4. Desktop Entry ---
banner
gum style --foreground "$PRIMARY" " ❯ Step 3: Menu Integration "

cat <<EOF > "$HOME/.local/share/applications/menuforge.desktop"
[Desktop Entry]
Name=MenuForge
Exec=menuforge
Icon=$ICON_PATH
Terminal=true
Type=Application
Categories=Utility;Game;
Comment=Universal app bridge by SahooShuvranshu & Crystal Studio Labs
Keywords=link;shortcut;app;game;install;bridge;menu;forge;
GenericName=App & Game Shortcut Creator
X-Created-By=MenuForge
EOF

# Refresh menu
if command -v walker &> /dev/null; then pkill -HUP walker; fi
if command -v rofi &> /dev/null; then pkill -HUP rofi 2>/dev/null; fi

gum style --foreground 10 "  [✔] Desktop entry created and menu refreshed."

# --- 5. Success ---
banner
gum style --foreground 10 --bold "✓ INSTALLATION COMPLETE!"
echo ""
gum format "
**MenuForge** is now ready for use.

- **Terminal:** Type 'menuforge'
- **Menu:** Search for 'MenuForge' or 'Bridge'

Enjoy forging your menu!
"
gum style --faint "Press any key to exit installer..."
read -n 1
