import SwiftUI
import SwiftData

struct StaffShiftPair: Identifiable {
    let id = UUID()
    let staff: Staff
    let shift: WorkShift
    
    var body: some View {
        VStack(alignment: .leading) {
            // Shift time formatting
            Text("\(formatTime(shift.startTime)) - \(formatTime(shift.endTime))")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Position text
            Text(shift.position.localized)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
