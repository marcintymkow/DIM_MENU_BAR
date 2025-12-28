# ☀️ DimMenuBar - Flat Design

Minimalistyczna kontrola jasności ekranu w menu bar macOS.

```
    ┌─────────────────────┐
    │         ◉           │
    │     BRIGHTNESS      │
    │        75%          │
    │  ────────●───────   │
    │                     │
    │  100  75  50  25 10 │
    │                     │
    │  RESET       QUIT   │
    └─────────────────────┘
```

## Szybka instalacja (automatyczna)

```bash
# Pobierz pliki i uruchom instalator
chmod +x install-dimmenubar.sh
./install-dimmenubar.sh install
```

**To wszystko!** Aplikacja:
- Zainstaluje się w `~/Applications/`
- Skonfiguruje autostart
- Uruchomi się od razu

## Zarządzanie

```bash
# Status instalacji
./install-dimmenubar.sh status

# Restart aplikacji
./install-dimmenubar.sh restart

# Zatrzymaj
./install-dimmenubar.sh stop

# Odinstaluj całkowicie
./install-dimmenubar.sh uninstall
```

## Ręczna instalacja

### 1. Kompilacja

```bash
# Stwórz strukturę aplikacji
mkdir -p ~/Applications/DimMenuBar.app/Contents/MacOS
mkdir -p ~/Applications/DimMenuBar.app/Contents/Resources

# Kompiluj
swiftc DimMenuBar.swift \
    -o ~/Applications/DimMenuBar.app/Contents/MacOS/DimMenuBar \
    -framework Cocoa \
    -O
```

### 2. Info.plist

```bash
cat > ~/Applications/DimMenuBar.app/Contents/Info.plist << 'EOF'
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
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF
```

### 3. LaunchAgent (Autostart)

```bash
# Skopiuj plist (zmień USER na swoją nazwę użytkownika)
cp com.local.dimmenubar.plist ~/Library/LaunchAgents/

# Edytuj ścieżkę w pliku
nano ~/Library/LaunchAgents/com.local.dimmenubar.plist
# Zmień /Users/TWOJ_USER/ na swoją ścieżkę

# Załaduj agent
launchctl load ~/Library/LaunchAgents/com.local.dimmenubar.plist
```

### 4. Uruchom

```bash
open ~/Applications/DimMenuBar.app
```

## Komendy LaunchAgent

```bash
# Załaduj (włącz autostart)
launchctl load ~/Library/LaunchAgents/com.local.dimmenubar.plist

# Wyładuj (wyłącz autostart)
launchctl unload ~/Library/LaunchAgents/com.local.dimmenubar.plist

# Sprawdź status
launchctl list | grep dimmenubar

# Uruchom ręcznie przez launchctl
launchctl start com.local.dimmenubar

# Zatrzymaj
launchctl stop com.local.dimmenubar
```

## Struktura plików

```
~/Applications/
└── DimMenuBar.app/
    └── Contents/
        ├── Info.plist
        ├── MacOS/
        │   └── DimMenuBar          # plik wykonywalny
        └── Resources/

~/Library/LaunchAgents/
└── com.local.dimmenubar.plist      # konfiguracja autostartu
```

## Funkcje

| Element | Opis |
|---------|------|
| ◉ Ikona | Biała ikona słońca w menu bar |
| Slider | Płynna regulacja 5%-100% |
| Presety | Szybkie przyciski: 100, 75, 50, 25, 10 |
| RESET | Przywróć 100% jasności |
| QUIT | Zamknij aplikację |

## Dostosowanie

### Zmiana zakresu jasności

W pliku `DimMenuBar.swift`, funkcja `setBrightness`:

```swift
// Minimalna jasność (domyślnie 5%)
currentBrightness = max(0.05, min(1.0, value))
//                      ↑ zmień na 0.01 dla 1%
```

### Reset jasności przy zamykaniu

Odkomentuj linię w `applicationWillTerminate`:

```swift
func applicationWillTerminate(_ notification: Notification) {
    BrightnessController.shared.resetBrightness()  // ← odkomentuj
}
```

### Zmiana kolorów interfejsu

W klasach widoków (`BrightnessMenuView`, itp.):

```swift
// Kolor tła
layer?.backgroundColor = NSColor(white: 0.1, alpha: 1.0).cgColor

// Kolor tekstu
titleLabel.textColor = NSColor.white.withAlphaComponent(0.5)
```

## Rozwiązywanie problemów

**Aplikacja nie startuje automatycznie?**

```bash
# Sprawdź czy plist jest załadowany
launchctl list | grep dimmenubar

# Sprawdź logi
cat /tmp/dimmenubar.error.log
```

**Ikona nie wyświetla się poprawnie?**

Na starszych wersjach macOS możesz zamienić rysowanie ikony na emoji:

```swift
button.title = "☀️"
button.image = nil
```

**Brak uprawnień?**

Dodaj aplikację w:
Ustawienia systemowe → Prywatność i bezpieczeństwo → Dostępność

## Wymagania

- macOS 11.0 (Big Sur) lub nowszy
- Xcode Command Line Tools (`xcode-select --install`)
