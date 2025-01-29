import Foundation
import SwiftData

@Model
class DishComponent {
    var name: String
    var amount: Double
    var unit: RecipeUnit
    @Relationship var recipe: Recipe?
    
    var inventoryStatus: (available: Bool, message: String) {
        guard let item = getInventoryItem() else {
            return (false, "not_linked_to_inventory".localized)
        }
        
        guard let convertedAmount = UnitConverter.convertToInventoryUnit(
            amount: amount,
            from: unit,
            to: item.unit
        ) else {
            return (false, "unit_conversion_impossible".localized)
        }
        
        if item.amount >= convertedAmount {
            return (true, "sufficient_stock".localized)
        } else {
            return (false, "insufficient_stock".localized)
        }
    }
    
    func getInventoryItem() -> InventoryItem? {
        // TODO: Implementoi varastotuotteen haku nimen perusteella
        return nil
    }
    
    func getRecipe(context: ModelContext) -> Recipe? {
        return recipe
    }
    
    init(name: String, amount: Double, unit: RecipeUnit, recipe: Recipe? = nil) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.recipe = recipe
    }
} 
