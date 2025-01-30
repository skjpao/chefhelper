import SwiftUI
import SwiftData

struct ComponentRow: View {
    let component: DishComponent
    let modelContext: ModelContext
    
    var body: some View {
        VStack(alignment: .leading) {
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
            
            // Poistetaan statuksen näyttäminen toistaiseksi
            // if !component.inventoryStatus.message.isEmpty {
            //     Text(component.inventoryStatus.message)
            //         .font(.caption)
            //         .foregroundColor(component.inventoryStatus.available ? .green : .red)
            // }
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
} 