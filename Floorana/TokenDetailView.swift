import SwiftUI

struct TokenDetailView: View {
    var nft: Nft

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
            indicator.padding(.vertical)
            VStack(alignment: .leading) {
                Text(nft.name).font(.title).bold().padding(.bottom)
                AsyncImage(url: URL(string: nft.image)!) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }.padding(.trailing, 8).padding(.bottom)
                Text("Attributes").font(.title2).bold()
                LazyVGrid(columns: [GridItem(.flexible(minimum: 120)), GridItem(.flexible(minimum: 120))], spacing: 20) {
                    ForEach(nft.attributes, id: \.type) { attribute in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(attribute.type).foregroundColor(Color(uiColor: .secondaryLabel)).minimumScaleFactor(0.8)
                                    .lineLimit(1)
                                Text(attribute.value).minimumScaleFactor(0.8)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }.frame(width: 120)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
            }.padding(20)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
