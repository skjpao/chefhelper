import Foundation
import SwiftData

@Model
class Recipe {
    var name: String
    @Relationship(deleteRule: .cascade) var ingredients: [Ingredient]
    var instructions: String
    var comments: [String]
    
    init(name: String, ingredients: [Ingredient], instructions: String, comments: [String] = []) {
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.comments = comments
    }
}