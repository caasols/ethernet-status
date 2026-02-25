import Foundation

protocol InterfaceSnapshotProviding: AnyObject {
    func snapshot(pathUsesWiredEthernet: Bool) -> InterfaceSnapshot
}

protocol PublicIPProviding: AnyObject {
    func fetchPublicIP(completion: @escaping @Sendable (String?) -> Void)
}

final class NetworkMonitorOrchestrator {
    private let interfaceProvider: InterfaceSnapshotProviding
    private let publicIPProvider: PublicIPProviding

    init(interfaceProvider: InterfaceSnapshotProviding, publicIPProvider: PublicIPProviding) {
        self.interfaceProvider = interfaceProvider
        self.publicIPProvider = publicIPProvider
    }

    func snapshot(pathUsesWiredEthernet: Bool) -> InterfaceSnapshot {
        interfaceProvider.snapshot(pathUsesWiredEthernet: pathUsesWiredEthernet)
    }

    func fetchPublicIP(showPublicIP: Bool, completion: @escaping @Sendable (String?) -> Void) {
        guard showPublicIP else {
            completion(nil)
            return
        }

        publicIPProvider.fetchPublicIP(completion: completion)
    }
}
