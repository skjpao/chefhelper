import SwiftUI
import SwiftData

@main
struct chefhelperApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            container = try ModelContainer(
                for: Recipe.self,
                RecipeIngredient.self,
                Dish.self,
                DishComponent.self,
                InventoryItem.self,
                Staff.self,
                WorkShift.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withLanguageManager()
        }
        .modelContainer(container)
    }
}
