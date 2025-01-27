import Foundation
import SwiftData

@Model
class InventoryItem {
    var name: String
    var amount: Double
    var unit: InventoryUnit
    var category: Category
    var pricePerUnit: Double // Hinta per yksikkö (kg/l/kpl)
    var expirationDate: Date?
    var minimumAmount: Double?
    var createdAt: Date
    var updatedAt: Date
    
    var totalValue: Double {
        return amount * pricePerUnit
    }
    
    var daysUntilExpiration: Int? {
        guard let expirationDate = expirationDate else { return nil }
        let calendar = Calendar.current
        
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExpiration = calendar.startOfDay(for: expirationDate)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiration)
        return components.day
    }
    
    var expirationText: String? {
        guard let days = daysUntilExpiration else { return nil }
        
        switch days {
        case 0:
            return "tänään"
        case 1:
            return "huomenna"
        case ..<0:
            return "vanhentunut"
        default:
            return "\(days) päivää"
        }
    }
    
    var isNearExpiration: Bool {
        guard let days = daysUntilExpiration else { return false }
        return days <= 7 && days >= 0
    }
    
    var isExpired: Bool {
        guard let days = daysUntilExpiration else { return false }
        return days < 0
    }
    
    var price: Double {
        return pricePerUnit * amount
    }
    
    init(name: String, amount: Double, unit: InventoryUnit, category: Category, pricePerUnit: Double, expirationDate: Date? = nil, minimumAmount: Double? = nil) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.category = category
        self.pricePerUnit = pricePerUnit
        self.expirationDate = expirationDate
        self.minimumAmount = minimumAmount
        self.createdAt = Date()
        self.updatedAt = Date()
    }
} 
