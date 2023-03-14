import SwiftUI

struct CollectionDetailView: View {
    var collection: Collection
    @Binding var showCollectionDetailView: Bool

    @State var showNftDetailView = false
    @State var nftDetail: Nft?

    var indicator: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.secondary)
            .frame(
                width: 60,
                height: 4
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                indicator.padding(.bottom)
                HStack {
                    AsyncImage(url: URL(string: collection.image)!) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(10)
                                .frame(width: 60, height: 60)
                        } else {
                            ProgressView()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                    }.padding(.trailing, 12)
                    Text(collection.name).font(.largeTitle).bold()
                    Spacer()
                }.padding(.bottom, 12)
                Text(collection.description).fontWeight(.thin).padding(.bottom, 20)
                HStack {
                    Spacer()
                    Text("\(collection.nfts.count) \(collection.nfts.count > 1 ? "Items" : "Item")").fontWeight(.light).foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                    ForEach(collection.nfts, id: \.name) { nft in
                        AsyncImage(url: URL(string: nft.image)!) { phase in
                            Button {
                                withAnimation {
                                    showNftDetailView = true
                                    nftDetail = nft
                                }
                            } label: {
                                VStack {
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .cornerRadius(15)
                                            .frame(width: 160, height: 160)
                                    } else {
                                        ProgressView()
                                            .frame(width: 160, height: 160)
                                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    }
                                    Text(nft.name).foregroundColor(Color.primary).fontWeight(.thin)
                                }
                            }
                        }
                    }
                }
            }.padding(20)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showNftDetailView) {
            if let nft = nftDetail {
                TokenDetailView(nft: nft)
            }
        }
    }
}
