import SwiftUI
import SwiftData

struct DishDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var dish: Dish
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let imageData = dish.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                }
                
                // Dish details section
                GroupBox(label: Label("dish_details".localized, systemImage: "list.bullet")) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(dish.name)
                            .font(.title2)
                            .bold()
                        
                        Text("components_title".localized + ":")
                            .font(.headline)
                        ForEach(dish.components) { component in
                            VStack(alignment: .leading) {
                                HStack {
                                    if let recipe = component.getRecipe(context: modelContext) {
                                        Text("\(recipe.name) (\("recipe_reference".localized))")
                                            .foregroundStyle(.brown)
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
                            .padding(.vertical, 2)
                        }
                        
                        Text("instructions_title".localized + ":")
                            .font(.headline)
                            .padding(.top)
                        Text(dish.instructions)
                            .padding(.leading)
                    }
                    .padding()
                }
                
                // Delete button
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("delete_dish".localized)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle(dish.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: { showingEditSheet = true }) {
                Text("edit".localized)
                    .foregroundColor(.brown)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditDishView(dish: dish)
        }
        .confirmationDialog(
            "delete_dish_confirmation".localized,
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("delete".localized, role: .destructive) {
                deleteDish()
            }
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("cannot_undo".localized)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
    
    private func deleteDish() {
        modelContext.delete(dish)
        dismiss()
    }
} 
