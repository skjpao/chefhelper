import Foundation
import SwiftData

@Model
class Staff {
    var name: String
    var role: String
    var contactInfo: String
    @Relationship(deleteRule: .cascade) var schedule: [WorkShift]
    var notes: String
    var color: String
    
    init(name: String, 
         role: Role,
         contactInfo: String, 
         schedule: [WorkShift] = [], 
         notes: String = "",
         color: String = "#1E88E5") {
            self.name = name
            self.role = role.rawValue
            self.contactInfo = contactInfo
            self.schedule = schedule
            self.notes = notes
            self.color = color
    }
} 
