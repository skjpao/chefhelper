import SwiftUI
import SwiftData

struct DayDetailView: View {
    let date: Date
    let staff: [Staff]
    @Binding var isPresented: Bool
    
    private let timeSlots = stride(from: 6, through: 23, by: 1).map { $0 }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(timeSlots, id: \.self) { hour in
                    let workingStaff = getWorkingStaff(at: hour)
                    if !workingStaff.isEmpty {
                        Section(header: Text("\(hour):00 - \(hour + 1):00")) {
                            ForEach(workingStaff) { pair in
                                StaffShiftRow(staff: pair.staff, shift: pair.shift)
                            }
                        }
                    }
                }
            }
            .navigationTitle(formatDate(date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Valmis") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func getWorkingStaff(at hour: Int) -> [StaffShiftPair] {
        var workingStaff: [StaffShiftPair] = []
        let calendar = Calendar.current
        
        for person in staff {
            for shift in person.schedule {
                let shiftHour = calendar.component(.hour, from: shift.startTime)
                let endHour = calendar.component(.hour, from: shift.endTime)
                
                if calendar.isDate(shift.date, inSameDayAs: date) &&
                   shiftHour <= hour && endHour > hour {
                    workingStaff.append(StaffShiftPair(staff: person, shift: shift))
                    break // Only add the first active shift for this person
                }
            }
        }
        
        return workingStaff
    }
}
