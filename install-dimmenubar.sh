#!/bin/bash

# ═══════════════════════════════════════════════════════════════
#  DimMenuBar - Instalator z Autostartem
# ═══════════════════════════════════════════════════════════════

set -e

APP_NAME="DimMenuBar"
INSTALL_DIR="$HOME/Applications"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="com.local.dimmenubar.plist"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           ☀️  DimMenuBar Installer                       ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ─────────────────────────────────────────────────────────────────
# Funkcje
# ─────────────────────────────────────────────────────────────────

install_app() {
    echo -e "${YELLOW}► Kompilacja aplikacji...${NC}"
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/$APP_NAME.app/Contents/MacOS"
    mkdir -p "$INSTALL_DIR/$APP_NAME.app/Contents/Resources"
    
    # Kompilacja
    swiftc "$SCRIPT_DIR/DimMenuBar.swift" \
        -o "$INSTALL_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME" \
        -framework Cocoa \
        -O
    
    # Info.plist
    cat > "$INSTALL_DIR/$APP_NAME.app/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>DimMenuBar</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.dimmenubar</string>
    <key>CFBundleName</key>
    <string>DimMenuBar</string>
    <key>CFBundleDisplayName</key>
    <string>DimMenuBar</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST
    
    echo -e "${GREEN}✓ Aplikacja zainstalowana: $INSTALL_DIR/$APP_NAME.app${NC}"
}

setup_autostart() {
    echo -e "${YELLOW}► Konfiguracja autostartu...${NC}"
    
    mkdir -p "$LAUNCH_AGENTS_DIR"
    
    # LaunchAgent plist
    cat > "$LAUNCH_AGENTS_DIR/$PLIST_NAME" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.dimmenubar</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <false/>
    
    <key>ProcessType</key>
    <string>Interactive</string>
    
    <key>StandardOutPath</key>
    <string>/tmp/dimmenubar.log</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/dimmenubar.error.log</string>
</dict>
</plist>
PLIST
    
    # Załaduj LaunchAgent
    launchctl unload "$LAUNCH_AGENTS_DIR/$PLIST_NAME" 2>/dev/null || true
    launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_NAME"
    
    echo -e "${GREEN}✓ Autostart skonfigurowany${NC}"
}

start_app() {
    echo -e "${YELLOW}► Uruchamianie aplikacji...${NC}"
    
    # Zamknij istniejącą instancję
    pkill -f "$APP_NAME.app" 2>/dev/null || true
    sleep 0.5
    
    # Uruchom
    open "$INSTALL_DIR/$APP_NAME.app"
    
    echo -e "${GREEN}✓ Aplikacja uruchomiona${NC}"
}

uninstall() {
    echo -e "${YELLOW}► Odinstalowywanie...${NC}"
    
    # Zatrzymaj LaunchAgent
    launchctl unload "$LAUNCH_AGENTS_DIR/$PLIST_NAME" 2>/dev/null || true
    
    # Zamknij aplikację
    pkill -f "$APP_NAME.app" 2>/dev/null || true
    
    # Usuń pliki
    rm -rf "$INSTALL_DIR/$APP_NAME.app"
    rm -f "$LAUNCH_AGENTS_DIR/$PLIST_NAME"
    
    # Reset jasności
    # Można użyć: osascript -e 'tell application "System Events" to key code 113' # F15 - zwiększ jasność
    
    echo -e "${GREEN}✓ Odinstalowano${NC}"
}

show_status() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Status instalacji:${NC}"
    echo ""
    
    if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
        echo -e "  Aplikacja:    ${GREEN}✓ Zainstalowana${NC}"
        echo -e "                $INSTALL_DIR/$APP_NAME.app"
    else
        echo -e "  Aplikacja:    ${RED}✗ Nie znaleziono${NC}"
    fi
    
    if [ -f "$LAUNCH_AGENTS_DIR/$PLIST_NAME" ]; then
        echo -e "  Autostart:    ${GREEN}✓ Skonfigurowany${NC}"
        
        if launchctl list | grep -q "com.local.dimmenubar"; then
            echo -e "  LaunchAgent:  ${GREEN}✓ Aktywny${NC}"
        else
            echo -e "  LaunchAgent:  ${YELLOW}○ Nieaktywny${NC}"
        fi
    else
        echo -e "  Autostart:    ${RED}✗ Nie skonfigurowany${NC}"
    fi
    
    if pgrep -f "$APP_NAME.app" > /dev/null; then
        echo -e "  Proces:       ${GREEN}✓ Uruchomiony${NC}"
    else
        echo -e "  Proces:       ${YELLOW}○ Nie uruchomiony${NC}"
    fi
    
    echo ""
}

show_help() {
    echo "Użycie: $0 [opcja]"
    echo ""
    echo "Opcje:"
    echo "  install     Zainstaluj aplikację i skonfiguruj autostart"
    echo "  uninstall   Odinstaluj aplikację"
    echo "  start       Uruchom aplikację"
    echo "  stop        Zatrzymaj aplikację"
    echo "  restart     Zrestartuj aplikację"
    echo "  status      Pokaż status instalacji"
    echo "  help        Pokaż tę pomoc"
    echo ""
    echo "Bez argumentów: pełna instalacja z autostartem"
}

# ─────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────

case "${1:-install}" in
    install)
        install_app
        setup_autostart
        start_app
        echo ""
        show_status
        echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  Instalacja zakończona! Ikona ☀️ widoczna w menu bar.${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
        ;;
    uninstall)
        uninstall
        echo -e "${GREEN}Odinstalowano pomyślnie.${NC}"
        ;;
    start)
        start_app
        ;;
    stop)
        pkill -f "$APP_NAME.app" 2>/dev/null || true
        echo -e "${GREEN}Aplikacja zatrzymana.${NC}"
        ;;
    restart)
        pkill -f "$APP_NAME.app" 2>/dev/null || true
        sleep 0.5
        open "$INSTALL_DIR/$APP_NAME.app"
        echo -e "${GREEN}Aplikacja zrestartowana.${NC}"
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Nieznana opcja: $1${NC}"
        show_help
        exit 1
        ;;
esac
