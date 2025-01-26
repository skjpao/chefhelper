import SwiftUI
import SwiftData

struct DishDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var dish: Dish
    @State private var showingEditSheet = false
    
    var body: some View {
        List {
            if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .listRowInsets(EdgeInsets())
            }
            
            Section(header: Text("Komponentit")) {
                ForEach(dish.components) { component in
                    VStack(alignment: .leading) {
                        HStack {
                            if let recipe = component.getRecipe(context: modelContext) {
                                Text("\(recipe.name) (resepti)")
                                    .foregroundStyle(.blue)
                            } else {
                                Text(component.name)
                            }
                            Spacer()
                            Text("\(formatAmount(component.amount)) \(component.unit.rawValue)")
                                .foregroundColor(.gray)
                        }
                        
                        // Varastotilanne
                        Text(component.inventoryStatus.message)
                            .font(.caption)
                            .foregroundColor(component.inventoryStatus.available ? .green : .red)
                    }
                }
            }
            
            if !dish.instructions.isEmpty {
                Section(header: Text("Valmistusohje")) {
                    Text(dish.instructions)
                }
            }
        }
        .navigationTitle(dish.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Muokkaa") {
                showingEditSheet = true
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditDishView(dish: dish)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
} 
