import SwiftUI
import SwiftData

struct ComponentRow: View {
    let component: DishComponent
    let modelContext: ModelContext
    
    var body: some View {
        HStack {
            if let recipe = component.recipe {
                Text("\(recipe.name) (\("recipe_reference".localized))")
                    .foregroundStyle(.brown)
            } else {
                Text(component.name)
            }
            Spacer()
            Text("\(formatAmount(component.amount)) \(component.unit.rawValue)")
                .foregroundColor(.gray)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
    
    private func deleteComponent() {
        if let recipe = component.recipe {
            component.recipe = nil
        }
        modelContext.delete(component)
    }
} 