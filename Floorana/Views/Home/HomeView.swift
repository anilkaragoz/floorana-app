import Combine
import SwiftUI

struct CollectionImageView: View {
    @State var collection: Collection

    var content: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(collection.name).font(.title2).fontWeight(.bold).lineLimit(3)
                Spacer()
                Text(collection.totalPrice.priceFormat + " SOL").font(.title3).fontWeight(.bold)
            }.padding(.bottom, 4)
            HStack {
                Text("\(collection.nfts.count) \(collection.nfts.count > 1 ? "Items" : "Item")").fontWeight(.light).foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                Spacer()
                VStack {
                    Text(collection.floorPrice.priceFormat + " SOL").fontWeight(.bold).foregroundColor(.MagicEdenPurple).padding(6)
                }.background(Color.MagicEdenPurple.opacity(0.2)).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }

    var body: some View {
        AsyncImage(
            url: URL(string: collection.image),
            transaction: Transaction(animation: .spring()),
            content: { phase in
                ZStack {
                    HStack(spacing: 12) {
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        } else {
                            ProgressView()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        content.padding(.top, 4)
                    }.padding()
                        .background(.thickMaterial)
                        .background(phase.image?.resizable().padding())
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
        )
    }
}

struct HomeView: View {
    @ObservedObject var viewModel = HomeViewModel()
    @State var showSettings = false

    var metadataProgressView: some View {
        VStack {
            HStack {
                Text("Fetching metadatas...").foregroundColor(Color(uiColor: .secondaryLabel)).fontWeight(.light)
                Spacer()
            }
            ProgressView(
                value: viewModel.progress,
                total: viewModel.totalProgress
            )
            .animation(.easeInOut, value: viewModel.progress)
            .tint(.MagicEdenPurple)
        }.padding()
    }

    var gallery: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.addresses.isEmpty {
                EmptyStateView {
                    showSettings = true
                }
            } else {
                header
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.collections, id: \.name) { collection in
                        Button {
                            viewModel.detailCollection = collection
                            viewModel.showDetailCollection = true
                        } label: {
                            CollectionImageView(collection: collection)
                        }.buttonStyle(ScaleButtonStyle())
                    }
                }.padding(.top, 40)
            }

        }.refreshable {
            viewModel.reload()
        }
    }

    var header: some View {
        VStack {
            HStack {
                Image("logo")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .opacity(0.5)
                    .padding(.leading, -12)
                Spacer()
                Button(action: {
                    showSettings.toggle()
                }) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                }.buttonStyle(BorderlessButtonStyle())
            }
            VStack {
                Text("CURRENT VALUE")
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                HStack {
                    Text("◎").font(.system(size: 30)).foregroundColor(Color(uiColor: .secondaryLabel))
                    Text(viewModel.walletTotal.priceFormat)
                        .font(.system(size: 60)).fontWeight(.bold)
                }

                Text("$ " + viewModel.walletTotalUsd.priceFormat)
                    .fontWeight(.light)
                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                if viewModel.showProgress {
                    metadataProgressView
                }
            }.padding(.top, 30)
        }.background(Color(uiColor: .secondarySystemBackground))
    }

    var body: some View {
        gallery.onAppear {
            viewModel.reload()
        }.padding()
            .background(Color(uiColor: UIColor.secondarySystemBackground))
            .padding(.top, 40)
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $showSettings, onDismiss: {
                viewModel.reload()
            }, content: {
                SettingsView {
                    viewModel.reload()
                    showSettings = false
                }.presentationDetents([.medium, .large])
            })
            .sheet(isPresented: $viewModel.showDetailCollection) {
                if let collection = viewModel.detailCollection {
                    CollectionDetailView(
                        collection: collection,
                        showCollectionDetailView: $viewModel.showDetailCollection
                    )
                }
            }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .preferredColorScheme(.dark)
        }
    }
}
