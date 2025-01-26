import SwiftUI

struct StaffShiftRow: View {
    let staff: Staff
    let shift: WorkShift
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: staff.color))
                .frame(width: 8, height: 8)
            Text(staff.name)
                .foregroundColor(.primary)
            Text(shift.position)
                .foregroundColor(.gray)
            Spacer()
            Text("\(formatTime(shift.startTime)) - \(formatTime(shift.endTime))")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
} 
