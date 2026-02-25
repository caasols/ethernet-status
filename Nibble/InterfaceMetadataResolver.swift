import Foundation
import SystemConfiguration

enum InterfaceMedium: Equatable {
    case wired
    case wiFi
    case vpn
    case bridge
    case loopback
    case awdl
    case bluetooth
    case unknown
}

enum InterfaceClassificationConfidence: Equatable {
    case high
    case low
}

struct InterfaceClassification: Equatable {
    let displayName: String
    let medium: InterfaceMedium
    let confidence: InterfaceClassificationConfidence
}

enum InterfaceMetadataResolver {
    static func classify(
        bsdName: String,
        systemType: String?,
        displayName: String?,
        fallbackTypeName: String?
    ) -> InterfaceClassification {
        if let systemType, let medium = mediumFromSystemType(systemType) {
            return InterfaceClassification(
                displayName: displayName ?? bsdName,
                medium: medium,
                confidence: .high
            )
        }

        if let fallbackTypeName, let medium = mediumFromFallbackTypeName(fallbackTypeName) {
            return InterfaceClassification(
                displayName: fallbackTypeName,
                medium: medium,
                confidence: .low
            )
        }

        return InterfaceClassification(
            displayName: bsdName,
            medium: mediumFromBSDName(bsdName),
            confidence: .low
        )
    }

    static func authoritativeMetadataByBSDName() -> [String: InterfaceClassification] {
        guard let raw = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface] else {
            return [:]
        }

        var result: [String: InterfaceClassification] = [:]
        for item in raw {
            guard let bsdName = SCNetworkInterfaceGetBSDName(item) as String? else {
                continue
            }

            let systemType = SCNetworkInterfaceGetInterfaceType(item) as String?
            let localizedName = SCNetworkInterfaceGetLocalizedDisplayName(item) as String?

            let classification = classify(
                bsdName: bsdName,
                systemType: systemType,
                displayName: localizedName,
                fallbackTypeName: nil
            )
            result[bsdName] = classification
        }

        return result
    }

    private static func mediumFromSystemType(_ systemType: String) -> InterfaceMedium? {
        let normalized = systemType.lowercased()

        if normalized == "ethernet" || normalized == "ieee8023adlag" || normalized == "firewire" {
            return .wired
        }

        if normalized == "ieee80211" {
            return .wiFi
        }

        if normalized == "bridge" {
            return .bridge
        }

        if normalized == "loopback" {
            return .loopback
        }

        if normalized == "vpn" || normalized == "ppp" || normalized == "ipsec" || normalized == "6to4" {
            return .vpn
        }

        if normalized == "bluetooth" {
            return .bluetooth
        }

        return nil
    }

    private static func mediumFromFallbackTypeName(_ typeName: String) -> InterfaceMedium? {
        let identity = typeName.lowercased()

        if identity.contains("wi-fi") || identity.contains("wifi") || identity.contains("airport") {
            return .wiFi
        }

        if identity.contains("bridge") {
            return .bridge
        }

        if identity.contains("vpn") {
            return .vpn
        }

        if identity.contains("ethernet") || identity.contains("lan") {
            return .wired
        }

        if identity.contains("awdl") {
            return .awdl
        }

        if identity.contains("bluetooth") {
            return .bluetooth
        }

        return nil
    }

    private static func mediumFromBSDName(_ bsdName: String) -> InterfaceMedium {
        if bsdName.starts(with: "lo") {
            return .loopback
        }

        if bsdName.starts(with: "bridge") {
            return .bridge
        }

        if bsdName.starts(with: "utun") {
            return .vpn
        }

        if bsdName.starts(with: "awdl") || bsdName.starts(with: "llw") {
            return .awdl
        }

        return .unknown
    }
}
