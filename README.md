# ☀️ DimMenuBar — flat design

Minimal screen brightness control from the macOS menu bar.

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

## Quick install (automated)

```bash
chmod +x install-dimmenubar.sh
./install-dimmenubar.sh install
```

That’s it. The installer:

- Builds and installs the app under `~/Applications/`
- Sets up a Launch Agent for login startup
- Launches the app immediately

## Managing the app

```bash
# Installation status
./install-dimmenubar.sh status

# Restart
./install-dimmenubar.sh restart

# Stop
./install-dimmenubar.sh stop

# Remove completely
./install-dimmenubar.sh uninstall
```

## Manual install

### 1. Build

```bash
mkdir -p ~/Applications/DimMenuBar.app/Contents/MacOS
mkdir -p ~/Applications/DimMenuBar.app/Contents/Resources

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

### 3. Launch Agent (autostart)

```bash
cp com.local.dimmenubar.plist ~/Library/LaunchAgents/

# Edit the path inside the plist to match your user home
nano ~/Library/LaunchAgents/com.local.dimmenubar.plist
# Replace /Users/TWOJ_USER/ with your actual path

launchctl load ~/Library/LaunchAgents/com.local.dimmenubar.plist
```

### 4. Run

```bash
open ~/Applications/DimMenuBar.app
```

## Launch Agent commands

```bash
# Load (enable autostart)
launchctl load ~/Library/LaunchAgents/com.local.dimmenubar.plist

# Unload (disable autostart)
launchctl unload ~/Library/LaunchAgents/com.local.dimmenubar.plist

# Check status
launchctl list | grep dimmenubar

# Start via launchctl
launchctl start com.local.dimmenubar

# Stop via launchctl
launchctl stop com.local.dimmenubar
```

## File layout

```
~/Applications/
└── DimMenuBar.app/
    └── Contents/
        ├── Info.plist
        ├── MacOS/
        │   └── DimMenuBar          # executable
        └── Resources/

~/Library/LaunchAgents/
└── com.local.dimmenubar.plist      # autostart config
```

## Features

| Item | Description |
|------|-------------|
| Sun icon | White sun icon in the menu bar |
| Slider | Smooth adjustment from 5% to 100% |
| Presets | Quick buttons: 100, 75, 50, 25, 10 |
| RESET | Restore 100% brightness |
| QUIT | Quit the app |

## How it works

DimMenuBar adjusts the **display gamma / transfer curve** for the main screen using Core Graphics (`CGSetDisplayTransferByFormula`). That dims what you see without changing the system brightness slider—useful when you want extra dimming or a software-only control from the bar.

## Customization

### Minimum brightness

In `DimMenuBar.swift`, inside `setBrightness`:

```swift
currentBrightness = max(0.05, min(1.0, value))
//                      ↑ change to 0.01 for 1% minimum
```

### Reset brightness on quit

Uncomment in `applicationWillTerminate`:

```swift
func applicationWillTerminate(_ notification: Notification) {
    BrightnessController.shared.resetBrightness()  // uncomment
}
```

### UI colors

In the view classes (`BrightnessMenuView`, etc.):

```swift
layer?.backgroundColor = NSColor(white: 0.1, alpha: 1.0).cgColor
titleLabel.textColor = NSColor.white.withAlphaComponent(0.5)
```

## Troubleshooting

**App does not start at login**

```bash
launchctl list | grep dimmenubar
cat /tmp/dimmenubar.error.log
```

**Icon looks wrong**

On older macOS versions you can switch to an emoji:

```swift
button.title = "☀️"
button.image = nil
```

**Permissions**

If macOS blocks interaction, try adding the app under  
**System Settings → Privacy & Security → Accessibility** (if prompted).

## Requirements

- macOS 11.0 (Big Sur) or later
- Xcode Command Line Tools (`xcode-select --install`)

License MIT

Author Marcin Tymków
