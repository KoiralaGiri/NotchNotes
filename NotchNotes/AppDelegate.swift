import Cocoa
import SwiftUI
import SwiftData

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app starts as a regular app with a Dock icon
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Configure the notch panel manager AFTER the app has fully launched
        // This avoids a race condition where the tracking window could
        // prevent the main SwiftUI window from appearing.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotchPanelManager.shared.configure(
                modelContainer: NotchNotesApp.sharedModelContainer
            )
        }
    }
    
    // Prevent the app from terminating when the last main window is closed.
    // This allows the menu bar / notch functionality to persist.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Hide the Dock icon when the user closes the main window
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
        return false
    }
    
    // Re-open the main window if the user clicks the Dock icon while it's closed
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Become a regular app again so the Dock icon reappears
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            
            // Find the main SwiftUI window and bring it front
            for window in NSApp.windows {
                if window.className == "SwiftUI.AppKitWindow" {
                    window.makeKeyAndOrderFront(nil)
                    break
                }
            }
        }
        return true
    }
}
