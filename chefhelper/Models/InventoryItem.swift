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
        return Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day
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
