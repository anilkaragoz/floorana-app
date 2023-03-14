import SwiftUI

struct AddressInputView: View {
    @State var address = ""
    @State var isAddEnabled = false
    @State var showAlert = false
    @FocusState private var isTextFieldFocused: Bool

    @Environment(\.presentationMode) var presentationMode

    var indicator: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.secondary)
            .frame(
                width: 60,
                height: 4
        )
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                indicator.padding(.top)
                Spacer()
            }
            Text("Add your solana address").font(.largeTitle).bold().padding(20)
            Spacer()
            TextField("Address", text: $address)
                .minimumScaleFactor(0.3)
                .lineLimit(1)
                .focused($isTextFieldFocused)
                .multilineTextAlignment(.center)
                .font(.custom("courier", size: 34))
                .foregroundColor(isAddEnabled ? Color.MagicEdenPurple : .secondary)
                .tint(Color.MagicEdenPurple)
                .accentColor(Color.MagicEdenPurple)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.isTextFieldFocused = true
                    }
                }
                .onChange(of: address) { newValue in
                    isAddEnabled = Solana.validateAddress(newValue)
                }
            Spacer()
            Button {
                addTapped()
            } label: {
                HStack {
                    Text("Done").font(.title2).fontWeight(.bold).padding(4).minimumScaleFactor(0.5)
                }
            }
            .disabled(!isAddEnabled)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Duplicate address"),
                    message: Text("This address has already been added.\nPlease try another one."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .buttonStyle(.bordered)
            .tint(Color.MagicEdenPurple)
            .padding(.bottom, 20)
        }
    }

    func addTapped() {
        guard SettingsManager.shared.addresses.contains(address) == false else {
            showAlert = true
            return
        }

        if Solana.validateAddress(address) {
            SettingsManager.shared.addresses.append(address)
            SettingsManager.shared.saveAddresses()

            UserDefaults.standard.set(nil, forKey: "snapshot_timestamp")

            presentationMode.wrappedValue.dismiss()
        }
    }
}


struct NewAddNewAddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressInputView().preferredColorScheme(.dark)
    }
}

struct OldAddNewAddressView: View {
    enum FocusField: Hashable {
        case field
    }

    @FocusState private var isTextFieldFocused: Bool
    @State var address = ""
    @State var isAddEnabled = false
    @State var showAlert = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Please make sure that you enter a valid solana address"),
                        footer: Text("• Address length should be between 32 and 44 caracters")) {
                    TextField("Enter Address", text: $address).focused($isTextFieldFocused).onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.isTextFieldFocused = true
                        }
                    }.onChange(of: address) { newValue in
                        isAddEnabled = Solana.validateAddress(newValue)
                    }
                }.textCase(nil)
                Section {
                    Button(action: pasteTapped) {
                        HStack {
                            Text("Paste from clipboard")
                            Spacer()
                            Image(systemName: "doc.on.clipboard")
                        }
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("New address")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel", action: {
                    presentationMode.wrappedValue.dismiss()
                }),
                trailing:
                Button("Add", action: addTapped)
                    .disabled(!isAddEnabled)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Duplicate address"),
                            message: Text("This address was already added.\nPlease try another one."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            )
        }
    }

    func pasteTapped() {
        guard let pasteboard = UIPasteboard.general.string else {
            return
        }

        address = pasteboard
        isAddEnabled = Solana.validateAddress(pasteboard)
    }

    func addTapped() {
        guard SettingsManager.shared.addresses.contains(address) == false else {
            showAlert = true
            return
        }

        if Solana.validateAddress(address) {
            SettingsManager.shared.addresses.append(address)
            SettingsManager.shared.saveAddresses()

            UserDefaults.standard.set(nil, forKey: "snapshot_timestamp")

            presentationMode.wrappedValue.dismiss()
        }
    }
}
