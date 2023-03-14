import Foundation

struct Nft: Codable {
    let mintAddress: String
    let name: String
    let collection: String?
    var image: String
    let attributes: [Attributes]

    struct Attributes: Codable {
        let type: String
        let value: String

        private enum CodingKeys: String, CodingKey {
            case type = "trait_type"
            case value = "value"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            type = try container.decode(String.self, forKey: .type)
            do {
                value = try String(container.decode(Int.self, forKey: .value))
            } catch DecodingError.typeMismatch {
                value = try container.decode(String.self, forKey: .value)
            }
        }
    }
}

struct CollectionStat: Codable {
    let symbol: String
    let floorPrice: Float?
}

struct Collection: Codable {
    var id = UUID()
    let symbol: String
    let name: String
    let image: String
    let description: String
    let floorPrice: Float
    let totalPrice: Float
    let nfts: [Nft]

    init(nfts: [Nft], collectionStats: CollectionStat, collectionDetail: CollectionDetail) {
        symbol = collectionDetail.symbol
        name = collectionDetail.name
        image = collectionDetail.image
        description = collectionDetail.description
        floorPrice = (collectionStats.floorPrice ?? 0.0) / 1_000_000_000
        totalPrice = Float(nfts.count) * floorPrice
        self.nfts = nfts
    }
}

struct CollectionDetail: Codable {
    let symbol: String
    let name: String
    let image: String
    let description: String
}

struct PriceResponse: Decodable {
    let solana: Solana

    struct Solana: Decodable {
        let usd: Double
        let eur: Double
    }
}

enum API {

    static func fetchWalletCollections(addresses: [String], onProgress: (Double) -> Void) async -> [Collection] {
        var nfts: [Nft] = []
        var progress = 0.0

        for address in addresses {
            print("Fetch address: \(address)")
            let addressNfts = await fetchNfts(address: address)
            nfts.append(contentsOf: addressNfts)
            try? await Task.sleep(nanoseconds: 500_000_000)
            progress += 1
            onProgress(progress)
        }

        let collectionsHash = Dictionary(grouping: nfts, by: { $0.collection ?? "Other" })
        let collectionNames = Array(collectionsHash.keys).filter { $0 != "Other" }
        let collectionStats = await getCollectionStats(collections: collectionNames)

        progress += 1
        onProgress(progress)

        try? await Task.sleep(nanoseconds: 500_000_000)
        let collectionDetails = await getCollectionsDetails(collections: collectionNames)

        let collections: [Collection] = collectionNames.map {
            Collection(nfts: collectionsHash[$0]!, collectionStats: collectionStats[$0]!, collectionDetail: collectionDetails[$0]!)
        }

        progress += 1
        onProgress(progress)

        return collections
    }

    static func fetchNfts(address: String) async -> [Nft] {
        let url = URL(string: "http://api-mainnet.magiceden.dev/v2/wallets/\(address)/tokens?offset=0&limit=500")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode([Nft].self, from: data)

            return decodedResponse
        } catch {
            print(error)
        }

        return []
    }

    static func getCollectionStats(collections: [String]) async -> [String: CollectionStat] {
        let encodedSymbols = collections.joined(separator: ",")

        let url = URL(string: "https://api-mainnet.magiceden.io/rpc/getMultiCollectionEscrowStats/\(encodedSymbols)")!

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode([CollectionStat].self, from: data)
            var res: [String: CollectionStat] = [:]
            decodedResponse.forEach { collectionStat in
                res[collectionStat.symbol] = collectionStat
            }

            return res
        } catch {
            print(error)
        }

        return [:]
    }

    private static func encodeCollections(collections: [String]) -> String {
        // "%5B" = [
        // "%5D" = ]
        // "%22" = "
        // "%2C" = ,

        guard collections.count > 0 else { return "" }

        var encodedString = "%5B"

        var previous: String?
        for collection in collections {
            if previous != nil {
                encodedString += "%2C"
            }

            encodedString += "%22\(collection)%22"

            previous = collection
        }

        encodedString += "%5D"

        return encodedString
    }

    static func getSolanaPrice() async -> Double {
        let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=eur%2Cusd")!

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PriceResponse.self, from: data)

            return decodedResponse.solana.usd
        } catch {
            print(error)
        }

        return 0.0
    }

    static func getCollectionsDetails(collections: [String]) async -> [String: CollectionDetail] {
        let encodedCollection = encodeCollections(collections: collections)

        let url = URL(string: "https://api-mainnet.magiceden.io/rpc/getCollectionsWithSymbols?symbols=\(encodedCollection)")!

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode([CollectionDetail].self, from: data)

            var res: [String: CollectionDetail] = [:]
            decodedResponse.forEach { collectionDetail in
                res[collectionDetail.symbol] = collectionDetail
            }

            return res
        } catch {
            print(error)
        }

        return [:]
    }
}
