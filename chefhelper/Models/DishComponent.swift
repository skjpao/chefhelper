import Foundation
import SwiftData

@Model
class DishComponent {
    var name: String
    var amount: Double
    var unit: RecipeUnit
    @Relationship(deleteRule: .nullify) var recipe: Recipe?
    
    var inventoryStatus: (available: Bool, message: String) {
        // Poistetaan varastotarkistus toistaiseksi
        return (true, "")  // Tyhjä viesti, jotta sitä ei näytetä
    }
    
    func getInventoryItem() -> InventoryItem? {
        return nil
    }
    
    init(name: String, amount: Double, unit: RecipeUnit, recipe: Recipe? = nil) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.recipe = recipe
    }
} 
