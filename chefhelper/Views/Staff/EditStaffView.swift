import SwiftUI
import SwiftData

struct EditStaffView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var staff: Staff
    @State private var selectedTab = 0
    
    @State private var name: String
    @State private var selectedRole: Role
    @State private var phoneNumber: String
    @State private var selectedColor: String
    @State private var showingShiftEditor = false
    
    init(staff: Staff) {
        self.staff = staff
        _name = State(initialValue: staff.name)
        _selectedRole = State(initialValue: staff.role)
        _phoneNumber = State(initialValue: staff.contactInfo)
        _selectedColor = State(initialValue: staff.color)
    }
    
    private var futureShifts: [WorkShift] {
        let now = Date()
        return staff.schedule.filter { shift in
            shift.endTime > now
        }.sorted { $0.startTime < $1.startTime }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Välilehdet
                Picker("Näkymä", selection: $selectedTab) {
                    Text("Työvuorot").tag(0)
                    Text("Tiedot").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    // Työvuoronäkymä
                    List {
                        if futureShifts.isEmpty {
                            Text("Ei tulevia työvuoroja")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(futureShifts) { shift in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(formatDate(shift.date))
                                            .font(.headline)
                                        Text("\(formatTime(shift.startTime)) - \(formatTime(shift.endTime))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text(shift.position)
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.brown.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                            .onDelete { indexSet in
                                // Muunnetaan futureShifts indeksit vastaamaan staff.schedule indeksejä
                                let shiftsToDelete = indexSet.map { futureShifts[$0] }
                                staff.schedule.removeAll { shift in
                                    shiftsToDelete.contains { $0.id == shift.id }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    
                    Button(action: { showingShiftEditor = true }) {
                        Label("Lisää työvuoro", systemImage: "plus")
                            .foregroundColor(.brown)
                            .padding()
                    }
                } else {
                    // Tietojen muokkausnäkymä
                    Form {
                        Section(header: Text("Perustiedot")) {
                            TextField("Nimi", text: $name)
                            Picker("Rooli", selection: $selectedRole) {
                                ForEach(Role.allCases, id: \.self) { role in
                                    Text(role.rawValue).tag(role)
                                }
                            }
                            TextField("Puhelinnumero", text: $phoneNumber)
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
                }
            }
            .navigationTitle(staff.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Sulje") {
                        dismiss()
                    }
                }
                if selectedTab == 1 {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Tallenna") {
                            saveChanges()
                        }
                        .disabled(name.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showingShiftEditor) {
                AddShiftView(staff: staff)
            }
        }
    }
    
    private func saveChanges() {
        staff.name = name
        staff.role = selectedRole
        staff.contactInfo = phoneNumber
        staff.color = selectedColor
        dismiss()
    }
}

struct RoleEditorView: View {
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
                            Text(role.rawValue)
                            Spacer()
                            if selectedRoles.contains(role) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Valitse roolit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valmis") {
                        dismiss()
                    }
                }
            }
        }
    }
} 