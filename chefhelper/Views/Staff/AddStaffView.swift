import SwiftUI
import SwiftData

struct AddStaffView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var selectedRole: Role = .cook
    @State private var contactInfo = ""
    @State private var selectedColor = colorOptions[0].hex
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Perustiedot")) {
                    TextField("Nimi", text: $name)
                    Picker("Rooli", selection: $selectedRole) {
                        ForEach(Role.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    TextField("Puhelinnumero", text: $contactInfo)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Väritunnus")) {
                    Picker("Väritunnus", selection: $selectedColor) {
                        ForEach(colorOptions) { color in
                            HStack {
                                Circle()
                                    .fill(Color(hex: color.hex))
                                    .frame(width: 20, height: 20)
                                Text(color.name)
                            }
                            .tag(color.hex)
                        }
                    }
                }
            }
            .navigationTitle("Lisää työntekijä")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") {
                        saveStaff()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveStaff() {
        let staff = Staff(
            name: name,
            role: selectedRole,
            contactInfo: contactInfo,
            color: selectedColor
        )
        modelContext.insert(staff)
        dismiss()
    }
} 
