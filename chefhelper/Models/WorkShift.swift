import Foundation
import SwiftData

@Model
class WorkShift {
    var id: UUID
    var date: Date
    var startTime: Date
    var endTime: Date
    var position: String
    
    init(date: Date, startTime: Date, endTime: Date, position: String) {
        self.id = UUID()
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.position = position
    }
} 