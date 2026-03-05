import Cocoa
import SwiftUI
import SwiftData

class NotchPanelManager: NSResponder {
    static let shared = NotchPanelManager()
    
    private var panel: KeyablePanel?
    private var hideTimer: Timer?
    private var globalPollTimer: Timer?
    
    private var isExpanded = false
    private var isPanelVisible = false
    
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
        
        panel.level = .screenSaver
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.contentViewController = hostingController
        // .fullScreenAuxiliary allows appearing over full screen apps, .canJoinAllSpaces shows on all desktops
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        // Allow the panel to be key so keyboard works and warnings go away
        panel.becomesKeyOnlyIfNeeded = true
        
        self.panel = panel
        
        positionPanel()
        
        // Start polling for mouse location globally
        startGlobalMousePoll()
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
    
    private func getTriggerRect() -> NSRect {
        guard let screen = NSScreen.main else { return .zero }
        let topSafeArea = screen.safeAreaInsets.top
        let notchWidth: CGFloat = 250
        let triggerHeight: CGFloat = max(topSafeArea, 24)
        
        let xPos = (screen.frame.width - notchWidth) / 2
        let yPos = screen.frame.height - triggerHeight
        return NSRect(x: xPos, y: yPos, width: notchWidth, height: triggerHeight)
    }
    
    private func startGlobalMousePoll() {
        globalPollTimer?.invalidate()
        // Poll at 10Hz (very low CPU) to check mouse position
        globalPollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.globalMousePollTick()
        }
    }
    
    private func globalMousePollTick() {
        let mouseLoc = NSEvent.mouseLocation
        let triggerRect = getTriggerRect()
        
        if triggerRect.contains(mouseLoc) {
            cancelHideTimer()
            showPanel()
        } else {
            // Only start hiding if panel is visible and mouse isn't hovering it
            if isPanelVisible && hideTimer == nil {
                startHideTimer()
            }
        }
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
        let triggerFrame = getTriggerRect().insetBy(dx: -20, dy: -10)
        
        if panelFrame.contains(mouseLoc) || triggerFrame.contains(mouseLoc) {
            hideTimer = nil // Allow polling to restart timer if needed
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
        NotificationCenter.default.post(name: NSNotification.Name("NotchPanelDidShow"), object: nil)
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
        if isExpanded {
            collapsePanel()
        } else {
            expandPanel()
        }
    }
    
    func expandPanel() {
        guard !isExpanded else { return }
        isExpanded = true
        animatePanelSize()
    }
    
    func collapsePanel() {
        guard isExpanded else { return }
        isExpanded = false
        animatePanelSize()
    }
    
    private func animatePanelSize() {
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
