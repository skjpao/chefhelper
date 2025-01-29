import SwiftUI
import SwiftData

struct EditStaffView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var staff: Staff
    @State private var selectedTab = 0
    @State private var showingDeleteAlert = false
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    @State private var name: String
    @State private var selectedRole: Role
    @State private var phoneNumber: String
    @State private var selectedColor: String
    @State private var showingShiftEditor = false
    @State private var selectedShiftTab = 0
    
    init(staff: Staff) {
        self.staff = staff
        _name = State(initialValue: staff.name)
        _selectedRole = State(initialValue: Role(rawValue: staff.role) ?? .cook)
        _phoneNumber = State(initialValue: staff.contactInfo)
        _selectedColor = State(initialValue: staff.color)
    }
    
    private var futureShifts: [WorkShift] {
        let now = Date()
        return staff.schedule.filter { shift in
            shift.endTime > now
        }.sorted { $0.startTime < $1.startTime }
    }
    
    private var pastShifts: [WorkShift] {
        let now = Date()
        return staff.schedule.filter { shift in
            shift.endTime <= now
        }.sorted { $0.startTime > $1.startTime }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tabs
                Picker("view".localized, selection: $selectedTab) {
                    Text("shifts".localized).tag(0)
                    Text("basic_info".localized).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    VStack(spacing: 0) {
                        // Shift tabs with rustic styling
                        ZStack {
                            Rectangle()
                                .fill(Color.brown.opacity(0.1))
                                .frame(height: 44)
                            
                            Picker("", selection: $selectedShiftTab) {
                                Text("upcoming_shifts".localized).tag(0)
                                Text("past_shifts".localized).tag(1)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 20)
                        }
                        
                        // Shift list
                        List {
                            let shifts = selectedShiftTab == 0 ? futureShifts : pastShifts
                            if shifts.isEmpty {
                                Text(selectedShiftTab == 0 ? "no_upcoming_shifts".localized : "no_past_shifts".localized)
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(shifts) { shift in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(formatDate(shift.date))
                                                .font(.headline)
                                            Text("\(formatTime(shift.startTime)) - \(formatTime(shift.endTime))")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text(shift.position.localized)
                                            .font(.caption)
                                            .padding(4)
                                            .background(Color.brown.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                .onDelete { indexSet in
                                    let shiftsToDelete = indexSet.map { shifts[$0] }
                                    staff.schedule.removeAll { shift in
                                        shiftsToDelete.contains { $0.id == shift.id }
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        
                        // Add shift button (only in upcoming tab)
                        if selectedShiftTab == 0 {
                            Button(action: { showingShiftEditor = true }) {
                                Label("add_shift".localized, systemImage: "plus")
                                    .foregroundColor(.brown)
                                    .padding()
                            }
                        }
                    }
                } else {
                    // Info editing view
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
                        
                        // Delete button section
                        Section {
                            Button(role: .destructive, action: { showingDeleteAlert = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("delete".localized)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle(staff.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if selectedTab == 1 {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("save".localized) {
                            validateAndSave()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingShiftEditor) {
                AddShiftView(staff: staff)
            }
            .alert("error".localized, isPresented: $showingValidationAlert) {
                Button("ok".localized, role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
            .confirmationDialog(
                "delete_staff_confirmation".localized,
                isPresented: $showingDeleteAlert,
                titleVisibility: .visible
            ) {
                Button("delete".localized, role: .destructive) {
                    deleteStaff()
                }
                Button("cancel".localized, role: .cancel) { }
            } message: {
                Text("cannot_undo".localized)
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
        saveChanges()
    }
    
    private func saveChanges() {
        staff.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        staff.role = selectedRole.rawValue
        staff.contactInfo = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        staff.color = selectedColor
        dismiss()
    }
    
    private func deleteStaff() {
        modelContext.delete(staff)
        dismiss()
    }
}

private struct RoleEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRoles: Set<Role>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Role.allCases, id: \.self) { role in
                    Button(action: {
                        if selectedRoles.contains(role) {
                            selectedRoles.remove(role)
                        } else {
                            selectedRoles.insert(role)
                        }
                    }) {
                        HStack {
                            Text(role.localizedName)
                            Spacer()
                            if selectedRoles.contains(role) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.brown)
                            }
                        }
                    }
                }
            }
            .navigationTitle("select_roles".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
} 
