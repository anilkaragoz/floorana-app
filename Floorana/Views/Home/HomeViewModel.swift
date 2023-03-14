import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var collections: [Collection] = []
    @Published var progress = 0.0
    @Published var totalProgress = 0.0
    @Published var walletTotal = 0.0
    @Published var walletTotalUsd = 0.0
    @Published var nftsCount = 0
    @Published var showProgress = false
    @Published var detailCollection: Collection? = nil
    @Published var showDetailCollection = false
    @Published var addresses: [String] = []

    private func saveToUserdefaults() {
        if let encoded = try? JSONEncoder().encode(collections) {
            UserDefaults.standard.set(encoded, forKey: "collections")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "snapshot_timestamp")
        }
    }

    private func savePrice(_ price: Double) {
        UserDefaults.standard.set(price, forKey: "solana_price_usd")
    }

    private func getLastSnapshotTimestamp() -> TimeInterval {
        return UserDefaults.standard.double(forKey: "snapshot_timestamp")
    }

    private func getSavedCollections() -> [Collection] {
        if let data = UserDefaults.standard.object(forKey: "collections") as? Data {
            if let savedData = try? JSONDecoder().decode([Collection].self, from: data) {
                return savedData
            }
        }
        return []
    }

    private func getSavedPrice() -> Double {
        return UserDefaults.standard.double(forKey: "solana_price_usd")
    }

    private func reload(useCache: Bool = true) {
        collections = getSavedCollections()
        let oldPrice = getSavedPrice()

        walletTotal = Double(collections.reduce(0.0) { $0 + $1.totalPrice })
        nftsCount = collections.reduce(0) { $0 + $1.nfts.count }
        walletTotalUsd = walletTotal * oldPrice

        addresses = SettingsManager.shared.addresses
        totalProgress = Double(SettingsManager.shared.addresses.isEmpty ? 0 : SettingsManager.shared.addresses.count + 2)

        guard useCache == false else {
            showProgress = false
            return
        }

        Task {
            let addresses = SettingsManager.shared.addresses

            showProgress = true

            collections = await API.fetchWalletCollections(addresses: addresses, onProgress: { progress in
                self.progress = progress
            }).sorted(by: { $0.floorPrice > $1.floorPrice })

            let newPrice = await API.getSolanaPrice()

            savePrice(newPrice)
            saveToUserdefaults()

            walletTotal = Double(collections.reduce(0.0) { $0 + $1.totalPrice })
            walletTotalUsd = walletTotal * newPrice
            nftsCount = collections.reduce(0) { $0 + $1.nfts.count }

            showProgress = false
            progress = 0
        }
    }

    func reload() {
        let currentTimestamp = Date().timeIntervalSince1970
        let lastTimestamp = getLastSnapshotTimestamp()
        let delta = currentTimestamp - lastTimestamp
        let minutes = Int(delta / 60)

        // Expire cache every 5 minutes
        reload(useCache: minutes < 1)
    }
}
