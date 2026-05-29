#!/bin/bash

# MenuForge v1.2.0 Core Library
# Shared architecture module for the MenuForge suite.
# Developed by SahooShuvranshu & Crystal Studio Labs

# --- Global State ---
export PRIMARY="#00D7FF"
export SECONDARY="#FFFFFF"
export HAS_NVIDIA=false
export PKG_MANAGER="unknown"
export INSTALL_CMD=""

# ---------------------------------------------------------
# Distro-Native Theme Engine
# ---------------------------------------------------------
detect_theme() {
    local GUM_CONF="$HOME/.config/omarchy/current/theme/gum.env.conf"
    if [ -f "$GUM_CONF" ]; then
        PRIMARY=$(grep "GUM_CHOOSE_CURSOR_FOREGROUND" "$GUM_CONF" | cut -d',' -f2 | tr -d '#' | head -n 1)
        [ -n "$PRIMARY" ] && PRIMARY="#$PRIMARY" || PRIMARY="#00D7FF"
        return
    fi

    if command -v kreadconfig5 &> /dev/null; then
        local ACCENT_RGB=$(kreadconfig5 --group "General" --key "AccentColor" 2>/dev/null)
        if [[ "$ACCENT_RGB" =~ ^([0-9]+),([0-9]+),([0-9]+)$ ]]; then
            PRIMARY=$(printf '#%02x%02x%02x\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}")
            return
        fi
    fi

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            arch|endeavouros) PRIMARY="#1793d1" ;;
            linuxmint) PRIMARY="#87cf3e" ;;
            fedora) PRIMARY="#294172" ;;
            opensuse*|suse) PRIMARY="#73ba25" ;;
            ubuntu) PRIMARY="#E95420" ;;
            debian) PRIMARY="#A80030" ;;
            pop) PRIMARY="#48B9C7" ;;
            *)
                if [[ "$ID_LIKE" == *"arch"* ]]; then PRIMARY="#1793d1"
                elif [[ "$ID_LIKE" == *"suse"* ]]; then PRIMARY="#73ba25"
                elif [[ "$ID_LIKE" == *"debian"* ]]; then PRIMARY="#A80030"
                else PRIMARY="#00D7FF"
                fi
                ;;
        esac
    fi
}

# ---------------------------------------------------------
# Hardware Architecture: NVIDIA Detection
# ---------------------------------------------------------
detect_nvidia() {
    if command -v lspci &> /dev/null; then
        if lspci -nn | grep -iE "vga|3d" | grep -iq "nvidia"; then
            HAS_NVIDIA=true
        fi
    fi
}

# ---------------------------------------------------------
# Distribution Interoperability: Package Routing
# ---------------------------------------------------------
detect_pkg_manager() {
    if command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        if command -v yay &> /dev/null; then
            INSTALL_CMD="yay -S --needed --noconfirm"
        elif command -v paru &> /dev/null; then
            INSTALL_CMD="paru -S --needed --noconfirm"
        else
            INSTALL_CMD="sudo pacman -S --needed --noconfirm"
        fi
    elif command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt-get install -y"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
        INSTALL_CMD="sudo zypper install -y"
    else
        PKG_MANAGER="unknown"
    fi
}

# ---------------------------------------------------------
# OS Resilience: Graceful Error Handling
# ---------------------------------------------------------
error_exit() {
    echo -e "\n\e[31m[✘] Error: $1\e[0m" >&2
    exit 1
}

# ---------------------------------------------------------
# Dynamic Dependency Resolver
# ---------------------------------------------------------
get_deps() {
    case "$PKG_MANAGER" in
        "pacman"|"apt") DEPS="gamemode mangohud gamescope wine imagemagick" ;;
        "dnf"|"zypper") DEPS="gamemode mangohud gamescope wine ImageMagick" ;;
        *) DEPS="" ;;
    esac

    if [ "$HAS_NVIDIA" = true ]; then
        case "$PKG_MANAGER" in
            "pacman"|"apt") DEPS="$DEPS nvidia-prime" ;;
            "dnf") DEPS="$DEPS akmod-nvidia" ;;
            "zypper") DEPS="$DEPS suse-prime" ;;
        esac
    fi
    echo "$DEPS"
}

# ---------------------------------------------------------
# UI Component: Branding Banner
# ---------------------------------------------------------
banner() {
    local title="${1:-MENUFORGE}"
    local subtitle="${2:-v1.2.0 | Developed by SahooShuvranshu & Crystal Studio Labs}"

    clear
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
        "$title" \
        "$subtitle"
    echo ""
}

# ---------------------------------------------------------
# System Audit: Doctor
# ---------------------------------------------------------
run_doctor() {
    banner "SYSTEM DOCTOR" "v1.2.0 | Integrity Audit Mode"
    
    echo " [01] Environment Audit..."
    echo -e "      OS: $([ -f /etc/os-release ] && grep "^NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '\"' || echo "Unknown")"
    echo -e "      Pkg Manager: $PKG_MANAGER"
    
    echo " [02] Dependency Verification..."
    for dep in gum gamemoderun mangohud gamescope wine lspci; do
        if command -v "$dep" &> /dev/null; then
            echo -e "      [✔] $dep: Integrated"
        else
            echo -e "      [✘] $dep: MISSING"
        fi
    done

    echo " [03] Hardware Probing..."
    detect_nvidia
    if [ "$HAS_NVIDIA" = true ]; then
        echo -e "      [✔] GPU: NVIDIA Detected (Prime-Run Available)"
    else
        echo -e "      [i] GPU: Non-NVIDIA / Integrated"
    fi

    echo " [04] Shortcut Integrity Scan..."
    local APP_DIR="$HOME/.local/share/applications"
    local BROKEN=0
    local TOTAL=0
    if [ -d "$APP_DIR" ]; then
        for f in "$APP_DIR"/menuforge_*.desktop; do
            [ -e "$f" ] || continue
            ((TOTAL++))
            local exec_cmd=$(grep "^Exec=" "$f" | cut -d'=' -f2- | sed 's/\"//g' | awk '{print $NF}')
            if [ ! -f "$exec_cmd" ] && [[ "$exec_cmd" != /* ]]; then
                command -v "$exec_cmd" &> /dev/null || { echo -e "      [!] Broken: $(basename "$f") (Target Missing)"; ((BROKEN++)); }
            elif [ ! -f "$exec_cmd" ]; then
                echo -e "      [!] Broken: $(basename "$f") (Target Missing)"; ((BROKEN++))
            fi
        done
    fi
    echo -e "      Result: $TOTAL Managed Links Found ($BROKEN Broken)"
    
    echo ""
    gum style --foreground "$PRIMARY" "Audit Complete. Infrastructure is $([ $BROKEN -eq 0 ] && echo "OPTIMAL" || echo "DEGRADED")."
}

# ---------------------------------------------------------
# Library Initialization Logic
# ---------------------------------------------------------
detect_theme
detect_nvidia
detect_pkg_manager
