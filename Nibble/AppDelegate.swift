import SwiftUI
import Network
import SystemConfiguration
import Combine

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!
    let settings: AppSettings
    @Published var networkMonitor: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        self.settings = AppSettings()
        self.networkMonitor = NetworkMonitor(settings: settings)
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            let initialDescriptor = MenuBarIconDescriptor.forConnectionState(networkMonitor.connectionState)
            button.image = NSImage(
                systemSymbolName: initialDescriptor.systemSymbolName,
                accessibilityDescription: initialDescriptor.accessibilityDescription
            )
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView()
                .environmentObject(self)
                .environmentObject(settings)
        )
        
        // Setup network monitoring
        networkMonitor.startMonitoring()

        // Apply initial app visibility mode
        applyActivationPolicy(startHidden: settings.startHidden)

        settings.$startHidden
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] startHidden in
                self?.applyActivationPolicy(startHidden: startHidden)
            }
            .store(in: &cancellables)
         
        // Update menu bar icon based on connection status
        updateMenuBarIcon()
    }

    func applicationWillTerminate(_ notification: Notification) {
        networkMonitor.stopMonitoring()
        cancellables.removeAll()
    }
    
    @objc func togglePopover() {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    func updateMenuBarIcon() {
        networkMonitor.$connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connectionState in
                if let button = self?.statusBarItem.button {
                    let descriptor = MenuBarIconDescriptor.forConnectionState(connectionState)
                    button.image = NSImage(
                        systemSymbolName: descriptor.systemSymbolName,
                        accessibilityDescription: descriptor.accessibilityDescription
                    )
                }
            }
            .store(in: &cancellables)
    }

    private func applyActivationPolicy(startHidden: Bool) {
        let policy: NSApplication.ActivationPolicy = startHidden ? .accessory : .regular
        NSApplication.shared.setActivationPolicy(policy)

        if !startHidden {
            NSApplication.shared.activate(ignoringOtherApps: false)
        }
    }
}
