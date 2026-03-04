import Cocoa
import SwiftUI
import SwiftData

class NotchPanelManager: NSResponder {
    static let shared = NotchPanelManager()
    
    private var panel: KeyablePanel?
    private var trackingWindow: NSWindow?
    private var isPanelVisible = false
    private var isExpanded = false
    private var hideTimer: Timer?
    
    // Model context to pass to the view
    var modelContainer: ModelContainer?
    
    private override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Call this explicitly from AppDelegate AFTER the app has finished launching.
    func configure(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        guard panel == nil else { return }
        setupPanel()
        setupTrackingArea()
    }
    
    private func setupPanel() {
        guard let modelContainer = modelContainer else { return }
        
        let contentView = NotchContentView()
            .modelContainer(modelContainer)
        
        let hostingController = NSHostingController(rootView: contentView)
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Use our custom KeyablePanel that properly supports becoming key
        let panel = KeyablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 200),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.contentViewController = hostingController
        panel.collectionBehavior = [.canJoinAllSpaces, .ignoresCycle]
        // Allow the panel to be key so keyboard works and warnings go away
        panel.becomesKeyOnlyIfNeeded = true
        
        self.panel = panel
        
        positionPanel()
    }
    
    private func setupTrackingArea() {
        guard let screen = NSScreen.main else { return }
        
        // Place the trigger zone right AT the notch / top of the screen
        // The notch area is within the safe area insets
        let topSafeArea = screen.safeAreaInsets.top
        let notchWidth: CGFloat = 250
        let triggerHeight: CGFloat = max(topSafeArea, 24) // Cover the notch itself
        
        // Position at the very top of the screen
        let xPos = (screen.frame.width - notchWidth) / 2
        let yPos = screen.frame.height - triggerHeight
        
        let triggerRect = NSRect(x: xPos, y: yPos, width: notchWidth, height: triggerHeight)
        
        let trackingWindow = NSWindow(
            contentRect: triggerRect,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        trackingWindow.level = .statusBar
        trackingWindow.backgroundColor = .clear
        trackingWindow.isOpaque = false
        trackingWindow.ignoresMouseEvents = false
        trackingWindow.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        
        // Setup tracking area on the content view
        let trackingArea = NSTrackingArea(
            rect: trackingWindow.contentView!.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        
        trackingWindow.contentView?.addTrackingArea(trackingArea)
        trackingWindow.orderFront(nil)
        
        self.trackingWindow = trackingWindow
    }
    
    private func positionPanel() {
        guard let panel = panel, let screen = NSScreen.main else { return }
        
        let safeAreaTop = screen.safeAreaInsets.top
        let availableHeight = screen.frame.height - safeAreaTop
        
        if isExpanded {
            // Expanded: nearly fullscreen
            let margin: CGFloat = 40
            let width = min(700, screen.frame.width - margin * 2)
            let height = availableHeight - margin
            let xPos = (screen.frame.width - width) / 2
            let yPos = margin
            panel.setFrame(NSRect(x: xPos, y: yPos, width: width, height: height), display: true)
        } else {
            // Compact: fixed reasonable height — content scrolls inside
            let width: CGFloat = 380
            let height: CGFloat = min(450, availableHeight * 0.55)
            let xPos = (screen.frame.width - width) / 2
            let yPos = screen.frame.height - safeAreaTop - height
            panel.setFrame(NSRect(x: xPos, y: yPos, width: width, height: height), display: true)
        }
    }
    
    // MARK: - Mouse Tracking
    
    override func mouseEntered(with event: NSEvent) {
        cancelHideTimer()
        showPanel()
    }
    
    override func mouseExited(with event: NSEvent) {
        startHideTimer()
    }
    
    func startHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.checkMouseLocationAndHide()
        }
    }
    
    func cancelHideTimer() {
        hideTimer?.invalidate()
        hideTimer = nil
    }
    
    private func checkMouseLocationAndHide() {
        let mouseLoc = NSEvent.mouseLocation
        
        let panelFrame = panel?.frame.insetBy(dx: -20, dy: -20) ?? .zero
        let triggerFrame = trackingWindow?.frame.insetBy(dx: -20, dy: -10) ?? .zero
        
        if panelFrame.contains(mouseLoc) || triggerFrame.contains(mouseLoc) {
            return
        }
        
        hidePanel()
    }
    
    func showPanel() {
        guard !isPanelVisible, let panel = panel else { return }
        
        positionPanel()
        
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1.0
        }
        
        isPanelVisible = true
    }
    
    func hidePanel() {
        guard isPanelVisible, let panel = panel else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0.0
        }, completionHandler: {
            panel.orderOut(nil)
            self.isPanelVisible = false
            // Reset expansion when hiding
            if self.isExpanded {
                self.isExpanded = false
            }
        })
    }
    
    // MARK: - Expand / Collapse
    
    func toggleExpand() {
        isExpanded.toggle()
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.35
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.allowsImplicitAnimation = true
            self.positionPanel()
        }
        
        // Refresh the content view to update its layout
        panel?.contentViewController?.view.needsLayout = true
    }
    
    var isPanelExpanded: Bool {
        return isExpanded
    }
}
