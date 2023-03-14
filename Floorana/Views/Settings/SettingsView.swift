import SwiftUI

struct AddressInputView_Previews: PreviewProvider {
    static var previews: some View {
        AddressInputView()
    }
}

struct SettingsView: View {
    @State var addresses: [String] = []
    @State var editMode: EditMode = .inactive
    @State var showSheet = false
    @State var isEditing = false

    var onChange: () -> ()

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Addresses").font(.largeTitle).bold()
                Spacer()
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation(.easeInOut) {
                        isEditing.toggle()
                        editMode = isEditing ? .active : .inactive
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(.blue)
            }.padding(20).listRowSeparator(.hidden)
            List {
                Button(action: {
                    showSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.app").resizable().frame(width: 20, height: 20).foregroundColor(Color.MagicEdenPurple)
                        Text("Add new address").bold().foregroundColor(Color.MagicEdenPurple)
                    }
                }.buttonStyle(BorderlessButtonStyle()).listRowSeparator(.hidden)
                ForEach(addresses, id: \.self) { address in
                    HStack {
                        Image(systemName: "personalhotspot").foregroundColor(Color(uiColor: .secondaryLabel))
                        Text(address.middleTruncated).fontWeight(.thin).font(.custom("courier", size: 16))
                    }
                }.onDelete(perform: delete)
            }.listStyle(PlainListStyle()).environment(\.editMode, $editMode)
        }
        .task {
            self.addresses = SettingsManager.shared.addresses
        }.sheet(isPresented: $showSheet, onDismiss: {
            self.addresses = SettingsManager.shared.addresses
            if self.addresses.count == 1 {
                presentationMode.wrappedValue.dismiss()
                onChange()
            }
        }) {
            AddressInputView().preferredColorScheme(.dark)
        }
    }

    func delete(index: IndexSet) {
        addresses.remove(atOffsets: index)

        SettingsManager.shared.addresses = addresses
        SettingsManager.shared.saveAddresses()

        UserDefaults.standard.set(nil, forKey: "snapshot_timestamp")
        
        onChange()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(addresses: ["JlkjdfJFSDF", "ssD3fjfdlku"], onChange: {}).preferredColorScheme(.dark)
    }
}

extension String {
    var middleTruncated: String {
        return "\(prefix(8))...\(suffix(8))"
    }
}
