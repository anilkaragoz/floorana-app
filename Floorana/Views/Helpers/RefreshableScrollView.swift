import SwiftUI
import UIKit

struct RefreshableScrollView<Content: View>: View {
    var onRefresh: () -> Void
    var showsIndicator: Bool
    var content: Content

    init(onRefresh: @escaping () -> Void, showsIndicator: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.onRefresh = onRefresh
        self.showsIndicator = showsIndicator
        self.content = content()

        UITableView.appearance().showsVerticalScrollIndicator = false
    }

    var body: some View {
        List {
            content
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable {
            onRefresh()
        }
    }
}


