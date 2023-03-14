import BackgroundTasks
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UIApplication.shared.setMinimumBackgroundFetchInterval(60 * 5)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        return true
    }

    func application(_: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Task {
            let lastSnapshot = getSavedCollections()
            await refresh {
                let newSnapshot = getSavedCollections()

                // ["collection": old, new]

                guard let highestChange = getHighestChange(oldSnapshot: lastSnapshot, newSnapshot: newSnapshot) else {
                    completionHandler(.noData)
                    return
                }

                let content = UNMutableNotificationContent()
                content.title = "Floor price increase"
                content.body = "\(highestChange.0.name)\n\(highestChange.0.floorPrice) SOL -> \(highestChange.1.floorPrice) SOL"
                content.sound = UNNotificationSound.default

                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

                UNUserNotificationCenter.current().add(request)

                completionHandler(.newData)
            }
        }
    }

    func getHighestChange(oldSnapshot: [Collection], newSnapshot: [Collection]) -> (Collection, Collection)? {
        let treshold: Float = 1.2

        var highestPercentage: Float = 0.0
        var highestChange: (Collection, Collection)?

        for newCollection in newSnapshot {
            if let oldCollection = oldSnapshot.first(where: { $0.symbol == newCollection.symbol }) {
                let percentage = newCollection.floorPrice / oldCollection.floorPrice
                if percentage >= treshold {
                    if percentage > highestPercentage {
                        highestPercentage = percentage
                        highestChange = (oldCollection, newCollection)
                    }
                }
            }
        }

        return highestChange
    }

    func saveToUserdefaults(collections: [Collection]) {
        if let encoded = try? JSONEncoder().encode(collections) {
            UserDefaults.standard.set(encoded, forKey: "collections")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "snapshot_timestamp")
        }
    }

    func getSavedCollections() -> [Collection] {
        if let data = UserDefaults.standard.object(forKey: "collections") as? Data {
            if let savedData = try? JSONDecoder().decode([Collection].self, from: data) {
                return savedData
            }
        }
        return []
    }

    func refresh(onSuccess: () -> Void) async {
        let addresses = SettingsManager.shared.addresses

        let collections = await API.fetchWalletCollections(addresses: addresses, onProgress: { _ in }).sorted(by: { $0.floorPrice > $1.floorPrice })
        saveToUserdefaults(collections: collections)

        onSuccess()
    }
}

@main
struct FlooranaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            HomeView().preferredColorScheme(.dark)
        }
    }
}
