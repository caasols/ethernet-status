import Foundation

enum EthernetConnectionState: Equatable {
    case active
    case inactive
    case disconnected

    var isConnected: Bool {
        self != .disconnected
    }
}

enum ConnectionStateEvaluator {
    static func evaluate(interfaces: [NetworkInterface], pathUsesWiredEthernet: Bool) -> EthernetConnectionState {
        guard ConnectionClassifier.hasWiredConnection(in: interfaces) else {
            return .disconnected
        }

        return pathUsesWiredEthernet ? .active : .inactive
    }
}
