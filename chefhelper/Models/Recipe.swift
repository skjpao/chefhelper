import SwiftData

@Model
class Recipe {
    var name: String
    @Relationship(deleteRule: .cascade) var ingredients: [RecipeIngredient]
    var instructions: String
    var comments: [String] = []
    var portionSize: Int
    
    var totalCost: Double {
        ingredients.reduce(0) { $0 + $1.cost }
    }
    
    var costPerPortion: Double {
        portionSize > 0 ? totalCost / Double(portionSize) : 0
    }
    
    var possiblePortions: Int {
        guard !ingredients.isEmpty else { 
            return 0 // "no_ingredients".localized
        }
        
        return ingredients.compactMap { ingredient -> Int? in
            guard let item = ingredient.inventoryItem else { 
                return nil // "ingredient_not_in_inventory".localized
            }
            let convertedAmount = ingredient.amount
            let possiblePortions = Int((item.amount / convertedAmount) * Double(portionSize))
            return possiblePortions
        }.min() ?? 0
    }
    
    init(name: String, ingredients: [RecipeIngredient], instructions: String, portionSize: Int = 1) {
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.portionSize = portionSize
    }
}
