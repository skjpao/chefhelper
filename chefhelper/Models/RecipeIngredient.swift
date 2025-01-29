import SwiftData

@Model
class RecipeIngredient {
    var name: String
    var amount: Double
    var unit: RecipeUnit
    var inventoryItem: InventoryItem?
    
    var cost: Double {
        guard let item = inventoryItem else { return 0 }
        return (amount / item.amount) * item.price
    }
    
    init(name: String, amount: Double, unit: RecipeUnit, inventoryItem: InventoryItem? = nil) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.inventoryItem = inventoryItem
    }
} 
