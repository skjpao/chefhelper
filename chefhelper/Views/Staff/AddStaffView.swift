import SwiftUI
import SwiftData

struct AddStaffView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var selectedRole: Role = .cook
    @State private var phoneNumber = ""
    @State private var selectedColor = colorOptions[0].hex
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("basic_info".localized)) {
                    TextField("name".localized, text: $name)
                    Picker("role".localized, selection: $selectedRole) {
                        ForEach(Role.allCases, id: \.self) { role in
                            Text(role.localizedName).tag(role)
                        }
                    }
                    TextField("phone_number".localized, text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("color_code".localized)) {
                    Picker("color_code".localized, selection: $selectedColor) {
                        ForEach(colorOptions) { color in
                            HStack {
                                Circle()
                                    .fill(Color(hex: color.hex))
                                    .frame(width: 20, height: 20)
                                Text(color.name.localized)
                            }
                            .tag(color.hex)
                        }
                    }
                }
            }
            .navigationTitle("add_staff".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("add".localized) {
                        validateAndSave()
                    }
                }
            }
            .alert("error".localized, isPresented: $showingValidationAlert) {
                Button("ok".localized, role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    private func isValidPhoneNumber(_ number: String) -> Bool {
        let phoneRegex = "^[0-9]{5,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: number.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private func validateAndSave() {
        // Tarkista nimi
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            validationMessage = "enter_staff_name".localized
            showingValidationAlert = true
            return
        }
        
        // Tarkista puhelinnumero
        let cleanedPhoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedPhoneNumber.isEmpty else {
            validationMessage = "enter_phone_number".localized
            showingValidationAlert = true
            return
        }
        
        guard isValidPhoneNumber(cleanedPhoneNumber) else {
            validationMessage = "invalid_phone_number".localized
            showingValidationAlert = true
            return
        }
        
        // Jos kaikki ok, tallenna
        let staff = Staff(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            role: selectedRole,
            contactInfo: cleanedPhoneNumber,
            color: selectedColor
        )
        
        modelContext.insert(staff)
        dismiss()
    }
} 
