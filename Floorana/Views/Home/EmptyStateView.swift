import SwiftUI

struct EmptyStateView: View {
    @State var isAnimating = false
    var onAddTapped: () -> Void

    var body: some View {
        VStack {
            Text("Welcome to your portfolio 👋").font(.largeTitle).bold().padding(.top, 40).padding(.bottom).fixedSize(horizontal: false, vertical: true)
            Image("logo")
                .opacity(self.isAnimating ? 0.3 : 1)
                .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                .onAppear {
                    self.isAnimating = true
                }
            Text("Add your address to get started").font(.body).fontWeight(.thin).foregroundColor(Color(uiColor: .secondaryLabel))
            Button {
                onAddTapped()
            } label: {
                HStack {
                    Text("Add my address").padding(4)
                }
            }
            .buttonStyle(.bordered)
            .tint(.MagicEdenPurple)
            .padding(.top)
        }.frame(maxWidth: .infinity)
    }
}
