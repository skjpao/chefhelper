import Foundation
import SwiftData

@Model
class Ingredient {
    var name: String
    var amount: Double
    var unit: Unit 
    var category: Category
    
    init(name: String, amount: Double, unit: Unit = .kg, category: Category = .misc) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.category = category
    }
} 