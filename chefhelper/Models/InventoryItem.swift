import Foundation
import SwiftData

@Model
class InventoryItem {
    var name: String
    var amount: Double
    var unit: Unit
    var category: Category
    var arrivalDate: Date
    var expiryDate: Date?
    
    init(name: String, amount: Double, unit: Unit, category: Category, arrivalDate: Date, expiryDate: Date? = nil) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.category = category
        self.arrivalDate = arrivalDate
        self.expiryDate = expiryDate
    }
} 
