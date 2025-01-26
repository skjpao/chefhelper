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
}
