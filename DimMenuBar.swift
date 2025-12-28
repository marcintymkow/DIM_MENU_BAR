#!/usr/bin/env swift
import Cocoa

// MARK: - Brightness Controller
class BrightnessController {
    static let shared = BrightnessController()
    
    private(set) var currentBrightness: Float = 1.0
    
    func setBrightness(_ value: Float) {
        currentBrightness = max(0.05, min(1.0, value))
        CGSetDisplayTransferByFormula(
            CGMainDisplayID(),
            0, currentBrightness, 1,
            0, currentBrightness, 1,
            0, currentBrightness, 1
        )
    }
    
    func resetBrightness() {
        CGDisplayRestoreColorSyncSettings()
        currentBrightness = 1.0
    }
}

// MARK: - Custom Menu View
class BrightnessMenuView: NSView {
    var slider: NSSlider!
    var percentLabel: NSTextField!
    var onSliderChange: ((Float) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(white: 0.1, alpha: 1.0).cgColor
        
        // Ikona słońca
        let sunIcon = NSTextField(frame: NSRect(x: 0, y: 90, width: bounds.width, height: 30))
        sunIcon.stringValue = "◉"
        sunIcon.font = NSFont.systemFont(ofSize: 28, weight: .ultraLight)
        sunIcon.textColor = .white
        sunIcon.alignment = .center
        sunIcon.isEditable = false
        sunIcon.isBordered = false
        sunIcon.backgroundColor = .clear
        addSubview(sunIcon)
        
        // Tytuł
        let titleLabel = NSTextField(frame: NSRect(x: 0, y: 68, width: bounds.width, height: 18))
        titleLabel.stringValue = "BRIGHTNESS"
        titleLabel.font = NSFont.systemFont(ofSize: 9, weight: .medium)
        titleLabel.textColor = NSColor.white.withAlphaComponent(0.5)
        titleLabel.alignment = .center
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        addSubview(titleLabel)
        
        // Procenty
        percentLabel = NSTextField(frame: NSRect(x: 0, y: 42, width: bounds.width, height: 26))
        percentLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 22, weight: .ultraLight)
        percentLabel.textColor = .white
        percentLabel.alignment = .center
        percentLabel.isEditable = false
        percentLabel.isBordered = false
        percentLabel.backgroundColor = .clear
        updatePercent(100)
        addSubview(percentLabel)
        
        // Slider
        slider = NSSlider(frame: NSRect(x: 20, y: 14, width: bounds.width - 40, height: 20))
        slider.minValue = 5
        slider.maxValue = 100
        slider.integerValue = 100
        slider.target = self
        slider.action = #selector(sliderMoved)
        slider.isContinuous = true
        addSubview(slider)
    }
    
    func updatePercent(_ value: Int) {
        percentLabel.stringValue = "\(value)%"
    }
    
    @objc func sliderMoved() {
        let value = Float(slider.integerValue) / 100.0
        updatePercent(slider.integerValue)
        onSliderChange?(value)
    }
}

// MARK: - Preset Button View
class PresetButtonView: NSView {
    var buttons: [NSButton] = []
    var onPresetSelected: ((Int) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(white: 0.1, alpha: 1.0).cgColor
        
        let presets = [100, 75, 50, 25, 10]
        let buttonWidth: CGFloat = 34
        let spacing: CGFloat = 6
        let totalWidth = CGFloat(presets.count) * buttonWidth + CGFloat(presets.count - 1) * spacing
        let startX = (bounds.width - totalWidth) / 2
        
        for (index, preset) in presets.enumerated() {
            let button = NSButton(frame: NSRect(
                x: startX + CGFloat(index) * (buttonWidth + spacing),
                y: 10,
                width: buttonWidth,
                height: 22
            ))
            button.title = "\(preset)"
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
            button.isBordered = false
            button.wantsLayer = true
            button.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.1).cgColor
            button.layer?.cornerRadius = 3
            button.contentTintColor = .white
            button.target = self
            button.action = #selector(presetClicked(_:))
            button.tag = preset
            
            // Hover effect
            let trackingArea = NSTrackingArea(
                rect: button.bounds,
                options: [.mouseEnteredAndExited, .activeAlways],
                owner: button,
                userInfo: nil
            )
            button.addTrackingArea(trackingArea)
            
            addSubview(button)
            buttons.append(button)
        }
    }
    
    @objc func presetClicked(_ sender: NSButton) {
        onPresetSelected?(sender.tag)
    }
}

// MARK: - Action Button View
class ActionButtonView: NSView {
    var onReset: (() -> Void)?
    var onQuit: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(white: 0.1, alpha: 1.0).cgColor
        
        // Reset button
        let resetButton = createFlatButton(
            frame: NSRect(x: 20, y: 10, width: 80, height: 24),
            title: "RESET",
            bgColor: NSColor.white.withAlphaComponent(0.08)
        )
        resetButton.target = self
        resetButton.action = #selector(resetClicked)
        addSubview(resetButton)
        
        // Quit button
        let quitButton = createFlatButton(
            frame: NSRect(x: bounds.width - 100, y: 10, width: 80, height: 24),
            title: "QUIT",
            bgColor: NSColor.white.withAlphaComponent(0.08)
        )
        quitButton.target = self
        quitButton.action = #selector(quitClicked)
        addSubview(quitButton)
    }
    
    private func createFlatButton(frame: NSRect, title: String, bgColor: NSColor) -> NSButton {
        let button = NSButton(frame: frame)
        button.title = title
        button.font = NSFont.systemFont(ofSize: 9, weight: .medium)
        button.isBordered = false
        button.wantsLayer = true
        button.layer?.backgroundColor = bgColor.cgColor
        button.layer?.cornerRadius = 3
        button.contentTintColor = .white
        return button
    }
    
    @objc func resetClicked() {
        onReset?()
    }
    
    @objc func quitClicked() {
        onQuit?()
    }
}

// MARK: - Menu Bar App
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var brightnessView: BrightnessMenuView!
    var presetView: PresetButtonView!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // Flat design - minimalistyczna ikona słońca (biała)
            let icon = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
                NSColor.white.setStroke()
                NSColor.white.setFill()
                
                // Środkowe kółko
                let center = NSPoint(x: 9, y: 9)
                let innerCircle = NSBezierPath(ovalIn: NSRect(x: 6, y: 6, width: 6, height: 6))
                innerCircle.fill()
                
                // Promienie - 8 linii
                let rayLength: CGFloat = 3
                let innerRadius: CGFloat = 5
                let angles: [CGFloat] = [0, 45, 90, 135, 180, 225, 270, 315]
                
                for angle in angles {
                    let rad = angle * .pi / 180
                    let startX = center.x + cos(rad) * innerRadius
                    let startY = center.y + sin(rad) * innerRadius
                    let endX = center.x + cos(rad) * (innerRadius + rayLength)
                    let endY = center.y + sin(rad) * (innerRadius + rayLength)
                    
                    let ray = NSBezierPath()
                    ray.move(to: NSPoint(x: startX, y: startY))
                    ray.line(to: NSPoint(x: endX, y: endY))
                    ray.lineWidth = 1.2
                    ray.lineCapStyle = .round
                    ray.stroke()
                }
                
                return true
            }
            icon.isTemplate = true
            button.image = icon
        }
        
        // Tworzenie menu
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        // Główny widok z sliderem
        let brightnessItem = NSMenuItem()
        brightnessView = BrightnessMenuView(frame: NSRect(x: 0, y: 0, width: 220, height: 130))
        brightnessView.onSliderChange = { [weak self] value in
            BrightnessController.shared.setBrightness(value)
        }
        brightnessItem.view = brightnessView
        menu.addItem(brightnessItem)
        
        // Presety
        let presetItem = NSMenuItem()
        presetView = PresetButtonView(frame: NSRect(x: 0, y: 0, width: 220, height: 42))
        presetView.onPresetSelected = { [weak self] preset in
            let value = Float(preset) / 100.0
            BrightnessController.shared.setBrightness(value)
            self?.brightnessView.slider.integerValue = preset
            self?.brightnessView.updatePercent(preset)
        }
        presetItem.view = presetView
        menu.addItem(presetItem)
        
        // Przyciski akcji
        let actionItem = NSMenuItem()
        let actionView = ActionButtonView(frame: NSRect(x: 0, y: 0, width: 220, height: 44))
        actionView.onReset = { [weak self] in
            BrightnessController.shared.resetBrightness()
            self?.brightnessView.slider.integerValue = 100
            self?.brightnessView.updatePercent(100)
        }
        actionView.onQuit = {
            NSApplication.shared.terminate(nil)
        }
        actionItem.view = actionView
        menu.addItem(actionItem)
        
        statusItem.menu = menu
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Opcjonalnie: reset jasności przy zamykaniu
        // BrightnessController.shared.resetBrightness()
    }
}

// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
