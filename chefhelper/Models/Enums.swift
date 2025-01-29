import SwiftUI
import Foundation

// Varaston yksiköt
enum InventoryUnit: String, Codable, CaseIterable {
    case kg = "kg"
    case l = "l"
    case kpl = "pcs"
    
    var localizedName: String {
        return self.rawValue.localized
    }
}

// Reseptien ja annosten yksiköt
enum RecipeUnit: String, Codable, CaseIterable {
    case g = "g"
    case dl = "dl"
    case kpl = "pcs"
    
    var localizedName: String {
        return self.rawValue.localized
    }
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
