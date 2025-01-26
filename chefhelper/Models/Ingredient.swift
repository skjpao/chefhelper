import Foundation
import SwiftData

@Model
class Ingredient {
    var name: String
    var amount: Double
    var unit: String
    
    init(name: String, amount: Double, unit: String) {
        self.name = name
        self.amount = amount
        self.unit = unit
    }
}

enum IngredientUnit: String, Codable, CaseIterable {
    case kg = "kg"
    case l = "l"
    case kpl = "kpl"
}