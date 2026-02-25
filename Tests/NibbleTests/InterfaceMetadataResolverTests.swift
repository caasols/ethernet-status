import Testing
@testable import Nibble

struct InterfaceMetadataResolverTests {
    @Test func prefersAuthoritativeSystemConfigurationTypeWhenAvailable() {
        let classification = InterfaceMetadataResolver.classify(
            bsdName: "en5",
            systemType: "Ethernet",
            displayName: "USB LAN",
            fallbackTypeName: "Wi-Fi"
        )

        #expect(classification.medium == .wired)
        #expect(classification.confidence == .high)
        #expect(classification.displayName == "USB LAN")
    }

    @Test func fallsBackToTypeLabelWhenSystemTypeMissing() {
        let classification = InterfaceMetadataResolver.classify(
            bsdName: "en0",
            systemType: nil,
            displayName: nil,
            fallbackTypeName: "Wi-Fi"
        )

        #expect(classification.medium == .wiFi)
        #expect(classification.confidence == .low)
        #expect(classification.displayName == "Wi-Fi")
    }

    @Test func fallsBackToBSDNamePatternAsLastResort() {
        let classification = InterfaceMetadataResolver.classify(
            bsdName: "bridge0",
            systemType: nil,
            displayName: nil,
            fallbackTypeName: nil
        )

        #expect(classification.medium == .bridge)
        #expect(classification.confidence == .low)
        #expect(classification.displayName == "bridge0")
    }
}
