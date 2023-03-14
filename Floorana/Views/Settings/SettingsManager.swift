import Foundation

class SettingsManager {
    public static let shared = SettingsManager()

    var addresses: [String] = []

    private init() {
        addresses = fetchAddresses()
    }

    func saveAddresses() {
        UserDefaults.standard.set(addresses, forKey: "settings.addresses")
    }

    func fetchAddresses() -> [String] {
        guard let fetchedAddresses = UserDefaults.standard.object(forKey: "settings.addresses") as? [String] else {
            return []
        }

        return fetchedAddresses
    }
}
