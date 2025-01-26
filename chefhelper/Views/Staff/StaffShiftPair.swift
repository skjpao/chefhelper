import SwiftUI
import SwiftData

struct StaffShiftPair: Identifiable {
    let id = UUID()
    let staff: Staff
    let shift: WorkShift
}
