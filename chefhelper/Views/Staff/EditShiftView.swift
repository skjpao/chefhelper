import SwiftUI
import SwiftData

struct EditShiftView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var staff: Staff
    @Bindable var shift: WorkShift
    
    @State private var date: Date
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var endHour: Int
    @State private var endMinute: Int
    @State private var showingDeleteAlert = false
    
    let hours = Array(6...22)
    let minutes = [0, 15, 30, 45]
    
    init(staff: Staff, shift: WorkShift) {
        self.staff = staff
        self.shift = shift
        
        let calendar = Calendar.current
        _date = State(initialValue: shift.date)
        _startHour = State(initialValue: calendar.component(.hour, from: shift.startTime))
        _startMinute = State(initialValue: calendar.component(.minute, from: shift.startTime))
        _endHour = State(initialValue: calendar.component(.hour, from: shift.endTime))
        _endMinute = State(initialValue: calendar.component(.minute, from: shift.endTime))
    }
    
    var body: some View {
        Form {
            Section(header: Text("shift_details".localized)) {
                DatePicker("date".localized, selection: $date, displayedComponents: .date)
                
                HStack {
                    Text("starts".localized)
                    Spacer()
                    Picker("", selection: $startHour) {
                        ForEach(hours, id: \.self) { hour in
                            Text(String(format: "%02d", hour)).tag(hour)
                        }
                    }
                    .frame(width: 60)
                    Text(":")
                    Picker("", selection: $startMinute) {
                        ForEach(minutes, id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .frame(width: 60)
                }
                
                HStack {
                    Text("ends".localized)
                    Spacer()
                    Picker("", selection: $endHour) {
                        ForEach(hours, id: \.self) { hour in
                            Text(String(format: "%02d", hour)).tag(hour)
                        }
                    }
                    .frame(width: 60)
                    Text(":")
                    Picker("", selection: $endMinute) {
                        ForEach(minutes, id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .frame(width: 60)
                }
            }
            
            Section {
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("delete_shift".localized)
                    }
                }
            }
        }
        .navigationTitle("edit_shift".localized)
        .navigationBarTitleDisplayMode(.inline)
        HStack {
            Button(action: { dismiss() }) {
                Text("cancel".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown.opacity(0.1))
                    .foregroundColor(.brown)
                    .cornerRadius(8)
            }
            Button(action: saveChanges) {
                Text("save".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .alert("delete_shift_confirmation".localized, isPresented: $showingDeleteAlert) {
            Button("delete".localized, role: .destructive) {
                deleteShift()
            }
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("cannot_undo".localized)
        }
    }
    
    private func saveChanges() {
        let calendar = Calendar.current
        
        var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
        startComponents.hour = startHour
        startComponents.minute = startMinute
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: date)
        endComponents.hour = endHour
        endComponents.minute = endMinute
        
        shift.date = date
        shift.startTime = calendar.date(from: startComponents) ?? date
        shift.endTime = calendar.date(from: endComponents) ?? date
        
        dismiss()
    }
    
    private func deleteShift() {
        if let index = staff.schedule.firstIndex(where: { $0.id == shift.id }) {
            staff.schedule.remove(at: index)
        }
        dismiss()
    }
} 