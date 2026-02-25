import Foundation

struct MenuBarIconDescriptor: Equatable {
    let systemSymbolName: String
    let accessibilityDescription: String

    static func forConnectionState(_ state: EthernetConnectionState) -> MenuBarIconDescriptor {
        switch state {
        case .active:
            return MenuBarIconDescriptor(
                systemSymbolName: "network",
                accessibilityDescription: "Ethernet Active"
            )
        case .inactive:
            return MenuBarIconDescriptor(
                systemSymbolName: "exclamationmark.network",
                accessibilityDescription: "Ethernet Inactive"
            )
        case .disconnected:
            return MenuBarIconDescriptor(
                systemSymbolName: "network.slash",
                accessibilityDescription: "Ethernet Disconnected"
            )
        }
    }
}
