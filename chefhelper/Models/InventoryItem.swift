import Foundation
import SwiftData
import SwiftUI

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
        
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let expiration = calendar.startOfDay(for: expirationDate)
        
        let components = calendar.dateComponents([.day], from: today, to: expiration)
        return components.day
    }
    
    var expirationText: String? {
        guard let days = daysUntilExpiration else { return nil }
        
        switch days {
        case 0:
            return "today".localized
        case 1:
            return "tomorrow".localized
        case ..<0:
            return "expired".localized
        default:
            return "\(days) \("days_remaining".localized)"
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
