import Cocoa

/// Custom NSPanel subclass that allows becoming the key window.
/// Fixes the "makeKeyWindow called on NSPanel which returned NO from canBecomeKeyWindow" warnings.
class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}
