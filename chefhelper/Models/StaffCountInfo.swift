import Foundation

struct StaffCountInfo: Identifiable {
    let id = UUID()
    let timeRange: String
    let staffByRole: [String: Int]  // role: count
    var totalStaff: Int { staffByRole.values.reduce(0, +) }
} 