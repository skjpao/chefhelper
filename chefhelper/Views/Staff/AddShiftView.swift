import SwiftUI
import SwiftData

struct AddShiftView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var staff: Staff
    
    @State private var date = Date()
    @State private var startHour = 8 // Default start hour
    @State private var startMinute = 0 // Default start minute
    @State private var endHour = 16 // Default end hour
    @State private var endMinute = 0 // Default end minute
    
    let hours = Array(6...22) // Working hours from 6 AM to 10 PM
    let minutes = [0, 15, 30, 45] // 15-minute intervals
    
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
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
            }
            .navigationTitle("add_shift".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("add".localized) {
                        addShift()
                    }
                }
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("ok".localized, role: .cancel) { }
        }
    }
    
    private func hasOverlappingShift() -> Bool {
        let calendar = Calendar.current
        
        var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
        startComponents.hour = startHour
        startComponents.minute = startMinute
        let newStartTime = calendar.date(from: startComponents) ?? date
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: date)
        endComponents.hour = endHour
        endComponents.minute = endMinute
        let newEndTime = calendar.date(from: endComponents) ?? date
        
        return staff.schedule.contains { existingShift in
            let shiftDate = calendar.startOfDay(for: existingShift.date)
            let newDate = calendar.startOfDay(for: date)
            
            guard shiftDate == newDate else { return false }
            return (newStartTime < existingShift.endTime && newEndTime > existingShift.startTime)
        }
    }
    
    private func addShift() {
        if hasOverlappingShift() {
            alertMessage = "overlapping_shift".localized
            showingAlert = true
            return
        }
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        components.hour = startHour
        components.minute = startMinute
        let startTime = Calendar.current.date(from: components) ?? date
        
        components.hour = endHour
        components.minute = endMinute
        let endTime = Calendar.current.date(from: components) ?? date
        
        let shift = WorkShift(
            date: date,
            startTime: startTime,
            endTime: endTime,
            position: staff.role
        )
        staff.schedule.append(shift)
        dismiss()
    }
} 
