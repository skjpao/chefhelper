import Foundation

// Varaston yksiköt
enum InventoryUnit: String, Codable, CaseIterable {
    case kg = "kg"
    case l = "l"
    case kpl = "kpl"
}

// Reseptien ja annosten yksiköt
enum RecipeUnit: String, Codable, CaseIterable {
    case g = "g"
    case dl = "dl"
    case kpl = "kpl"
}

// Yksikkömuunnokset
struct UnitConverter {
    static func convertToInventoryUnit(amount: Double, from: RecipeUnit, to: InventoryUnit) -> Double? {
        switch (from, to) {
        case (.g, .kg):
            return amount / 1000
        case (.dl, .l):
            return amount / 10
        case (.kpl, .kpl):
            return amount
        default:
            return nil
        }
    }
    
    static func convertToRecipeUnit(amount: Double, from: InventoryUnit, to: RecipeUnit) -> Double? {
        switch (from, to) {
        case (.kg, .g):
            return amount * 1000
        case (.l, .dl):
            return amount * 10
        case (.kpl, .kpl):
            return amount
        default:
            return nil
        }
    }
}

enum Category: String, Codable, CaseIterable {
    case all = "Kaikki"
    case fresh = "Tuoretuotteet"
    case dry = "Kuiva-aineet"
    case misc = "Muut"
    
    static var addCases: [Category] {
        [.fresh, .dry, .misc]
    }
}

enum Role: String, Codable, CaseIterable {
    case cook = "Kokki"
    case waiter = "Tarjoilija"
    case dishwasher = "Tiskari"
    case kitchenSupervisor = "Vuoropäällikkö (keittiö)"
    case serviceSupervisor = "Vuoropäällikkö (sali)"
    case headChef = "Keittiömestari"
    case restaurantManager = "Ravintolapäällikkö"
} 
