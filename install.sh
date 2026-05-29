#!/bin/bash

# MenuForge v1.2.0 Installer
# Universal Linux deployment architecture for MenuForge components.
# Developed by SahooShuvranshu & Crystal Studio Labs

if [ -z "$BASH_VERSION" ]; then
    echo "Error: This script must be run with bash."
    exit 1
fi

# Flag: --needed (Non-interactive mode)
HEADLESS=false
[[ "$1" == "--needed" ]] && HEADLESS=true

# ---------------------------------------------------------
# Modular Core Loading
# ---------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_PATH="$SCRIPT_DIR/menuforge-lib.sh"
[ -f "$LIB_PATH" ] || LIB_PATH="./menuforge-lib.sh"

if [ -f "$LIB_PATH" ]; then
    source "$LIB_PATH"
else
    echo "Fatal Infrastructure Error: menuforge-lib.sh not found."
    exit 1
fi

# ---------------------------------------------------------
# Bootstrapper: TUI Framework (Gum)
# ---------------------------------------------------------
install_gum() {
    if ! command -v gum &> /dev/null; then
        echo "Initializing TUI Layer: Installing 'gum' framework..."
        case "$PKG_MANAGER" in
            "pacman") 
                $INSTALL_CMD gum || error_exit "Failed to deploy TUI dependencies."
                ;;
            "apt")
                sudo mkdir -p /etc/apt/keyrings
                command -v curl &> /dev/null || sudo apt-get install -y curl
                command -v gpg &> /dev/null || sudo apt-get install -y gpg
                curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
                echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
                sudo apt-get update && sudo apt-get install -y gum || error_exit "Failed to deploy TUI dependencies."
                ;;
            "dnf")
                echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
                sudo dnf install -y gum || error_exit "Failed to deploy TUI dependencies."
                ;;
            "zypper")
                sudo zypper addrepo https://repo.charm.sh/yum/ charm
                sudo zypper install -y gum || error_exit "Failed to deploy TUI dependencies."
                ;;
            *) error_exit "Incompatible Environment: Please install 'gum' manually (https://github.com/charmbracelet/gum)." ;;
        esac
    fi
}

install_gum

# --- 1. Welcome Screen ---
if [ "$HEADLESS" = false ]; then
    banner "MENUFORGE INSTALLER" "v1.2.0 | Developed by SahooShuvranshu & Crystal Studio Labs"
    gum format "
### WELCOME
This architecture will deploy **MenuForge v1.2.0** to your system.

**Strategic Deployment Steps:**
1. OS Interoperability Check & Dependency Resolution
2. Binary & Logic Library Deployment
3. Desktop Environment Integration (XDG Launcher)

*Press [ENTER] to initiate system deployment...*
"
    gum input --placeholder "" --password &> /dev/null
fi

# --- 2. Dependencies ---
if [ "$HEADLESS" = false ]; then banner "STEP 1: DEPENDENCIES"; fi
echo "Detecting required components..."

DEPS=$(get_deps)
if [ "$HEADLESS" = false ]; then
    echo "The following packages will be installed: $DEPS"
    echo "This process may take a while depending on your internet speed."
    echo ""
    echo "Please authenticate to proceed with system installation:"
    sudo -v || error_exit "Sudo authentication failed."

    gum spin --spinner dot --title "Forging system dependencies... (Downloading & Installing)" -- \
        bash -c "$INSTALL_CMD $DEPS" || gum style --foreground 3 "  [!] Dependency sync completed with warnings."
else
    # Headless installation
    bash -c "$INSTALL_CMD $DEPS" || echo "Warning: Dependency sync encountered issues."
fi

# --- 3. File Deployment ---
if [ "$HEADLESS" = false ]; then banner "STEP 2: DEPLOYMENT"; fi

BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"

mkdir -p "$BIN_DIR" "$APP_DIR" "$ICON_DIR" || error_exit "Failed to create local directories."

cp menuforge-lib.sh "$BIN_DIR/menuforge-lib.sh" || error_exit "Failed to deploy core library."

if [ -f "menuforge" ]; then
    cp menuforge "$BIN_DIR/menuforge" && chmod +x "$BIN_DIR/menuforge" || error_exit "Failed to deploy 'menuforge'."
    [ "$HEADLESS" = false ] && gum style --foreground 10 "  [✔] Binary: ~/.local/bin/menuforge"
else
    error_exit "'menuforge' source file missing."
fi

if [ -f "menuforge-dep-installer" ]; then
    cp menuforge-dep-installer "$BIN_DIR/menuforge-dep-installer" && chmod +x "$BIN_DIR/menuforge-dep-installer" || error_exit "Failed to deploy 'menuforge-dep-installer'."
    [ "$HEADLESS" = false ] && gum style --foreground 10 "  [✔] Helper: ~/.local/bin/menuforge-dep-installer"
fi

if [ -f "assets/logo.png" ]; then
    cp assets/logo.png "$ICON_DIR/menuforge.png"
    ICON_PATH="$ICON_DIR/menuforge.png"
    [ "$HEADLESS" = false ] && gum style --foreground 10 "  [✔] Asset: Official icon deployed"
else
    ICON_PATH="terminal"
fi

# --- 4. Desktop Entry ---
if [ "$HEADLESS" = false ]; then banner "STEP 3: INTEGRATION"; fi

cat <<EOF > "$APP_DIR/menuforge.desktop"
[Desktop Entry]
Name=MenuForge
Exec=menuforge
Icon=$ICON_PATH
Terminal=true
Type=Application
Categories=Utility;Game;
Comment=Universal app bridge by SahooShuvranshu & Crystal Studio Labs
X-Created-By=MenuForge
EOF
[ $? -eq 0 ] || error_exit "Failed to create desktop entry."

# Refresh Menus
for tool in walker rofi wofi; do command -v "$tool" &> /dev/null && pkill -HUP "$tool" 2>/dev/null; done

if [ "$HEADLESS" = false ]; then
    banner "SUCCESS"
    gum style --foreground 10 --bold "✓ INSTALLATION COMPLETE!"
    echo ""
    gum format "**MenuForge** is now integrated. Type 'menuforge' in your terminal or find it in your app menu."
    gum style --faint "Press any key to exit..."
    read -n 1
else
    echo "MenuForge v1.2.0 deployment completed successfully."
fi
