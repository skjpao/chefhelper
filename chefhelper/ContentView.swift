import SwiftUI
import SwiftData
import Foundation

#if DEBUG
extension ContentView {
    func isUITesting() -> Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-testing")
    }
}
#endif



// Main view with tabs
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            RecipeListView()
                .tabItem {
                    Label("Reseptit", systemImage: "book")
                }
            
            InventoryView()
                .tabItem {
                    Label("Varasto", systemImage: "cube.box")
                }
            
            StaffView()
                .tabItem {
                    Label("Henkilöstö", systemImage: "person.2")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Recipe.self,
            Ingredient.self,
            InventoryItem.self,
            Staff.self,
            WorkShift.self,
        ], inMemory: true)
}
