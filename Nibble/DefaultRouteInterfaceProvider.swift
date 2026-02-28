import Foundation
import SystemConfiguration

protocol DefaultRouteInterfaceProviding: AnyObject {
    func currentDefaultRouteInterfaceName() -> String?
}

final class DefaultRouteInterfaceProvider: DefaultRouteInterfaceProviding {
    func currentDefaultRouteInterfaceName() -> String? {
        guard let store = SCDynamicStoreCreate(nil, "NibbleDefaultRoute" as CFString, nil, nil) else {
            return nil
        }

        let ipv4Key = "State:/Network/Global/IPv4" as CFString
        guard let value = SCDynamicStoreCopyValue(store, ipv4Key) as? [String: Any] else {
            return nil
        }

        return value["PrimaryInterface"] as? String
    }
}
