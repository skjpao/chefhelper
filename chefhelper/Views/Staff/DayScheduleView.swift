import SwiftUI
import SwiftData

// Update DayScheduleView with improved staff counting
struct DayScheduleView: View {
    let date: Date
    let staff: [Staff]
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(formatDate(date))
                .font(.caption.bold())
                .padding(.bottom, 4)
            
            // Staff count preview with improved layout
            VStack(alignment: .leading, spacing: 4) {
                let staffCounts = getStaffCounts()
                ForEach(staffCounts) { timeSlot in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(timeSlot.timeRange)
                            .font(.caption.bold())
                        ForEach(timeSlot.staffByRole.sorted(by: { $0.key < $1.key }), id: \.key) { role, count in
                            Text("\(count) \(role.localized)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(6)
            .background(Color.brown.opacity(0.05))
            .cornerRadius(6)
        }
        .frame(width: 100)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedDate = date
        }
        .sheet(isPresented: Binding(
            get: { selectedDate == date },
            set: { if !$0 { selectedDate = nil } }
        )) {
            DayDetailView(date: date, staff: staff, isPresented: Binding(
                get: { selectedDate == date },
                set: { if !$0 { selectedDate = nil } }
            ))
        }
    }
    
    private func getStaffCounts() -> [StaffCountInfo] {
        // Get all shifts for this date
        let shifts = staff.flatMap { person in
            person.schedule.compactMap { shift in
                Calendar.current.isDate(shift.date, inSameDayAs: date) ? (person, shift) : nil
            }
        }
        
        guard !shifts.isEmpty else { return [] }
        
        // Find all unique time points where staff changes
        var timePoints = Set<Date>()
        shifts.forEach { _, shift in
            timePoints.insert(shift.startTime)
            timePoints.insert(shift.endTime)
        }
        
        let sortedTimes = timePoints.sorted()
        var results: [StaffCountInfo] = []
        
        // For each time segment between changes
        for i in 0..<(sortedTimes.count - 1) {
            let startTime = sortedTimes[i]
            let endTime = sortedTimes[i + 1]
            
            // Count staff by role during this time segment
            var staffByRole: [String: Int] = [:]
            for (_, shift) in shifts {
                if shift.startTime <= startTime && shift.endTime >= endTime {
                    staffByRole[shift.position, default: 0] += 1
                }
            }
            
            // Only add if there are staff working
            if !staffByRole.isEmpty {
                results.append(StaffCountInfo(
                    timeRange: "\(formatTime(startTime))-\(formatTime(endTime))",
                    staffByRole: staffByRole
                ))
            }
        }
        
        // Combine consecutive time slots with identical staff counts
        return combineSimilarTimeSlots(results)
    }
    
    private func combineSimilarTimeSlots(_ slots: [StaffCountInfo]) -> [StaffCountInfo] {
        guard var current = slots.first else { return [] }
        var combined: [StaffCountInfo] = []
        var startTime = current.timeRange.components(separatedBy: "-")[0]
        
        for next in slots.dropFirst() {
            if current.staffByRole == next.staffByRole {
                // Continue the current time slot
                continue
            } else {
                // Add the completed time slot and start a new one
                let endTime = current.timeRange.components(separatedBy: "-")[1]
                combined.append(StaffCountInfo(
                    timeRange: "\(startTime)-\(endTime)",
                    staffByRole: current.staffByRole
                ))
                current = next
                startTime = next.timeRange.components(separatedBy: "-")[0]
            }
        }
        
        // Add the last time slot
        let endTime = slots.last?.timeRange.components(separatedBy: "-")[1] ?? ""
        combined.append(StaffCountInfo(
            timeRange: "\(startTime)-\(endTime)",
            staffByRole: current.staffByRole
        ))
        
        return combined
    }
}
