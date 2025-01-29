import Foundation
import SwiftData

@Model
class Dish {
    var name: String
    @Relationship(deleteRule: .cascade) var components: [DishComponent]
    var instructions: String
    var imageData: Data?
    
    init(name: String, components: [DishComponent] = [], instructions: String = "", imageData: Data? = nil) {
        self.name = name
        self.components = components
        self.instructions = instructions
        self.imageData = imageData
    }
    
    // Inventory status messages
    var inventoryStatus: (available: Bool, message: String) {
        let componentStatuses = components.map { $0.inventoryStatus }
        
        if componentStatuses.isEmpty {
            return (false, "no_components".localized)
        }
        
        if componentStatuses.allSatisfy({ $0.available }) {
            return (true, "all_components_available".localized)
        } else {
            return (false, "missing_components".localized)
        }
    }
}
