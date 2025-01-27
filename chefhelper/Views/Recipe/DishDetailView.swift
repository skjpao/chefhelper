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
                GroupBox(label: Label("Annoksen tiedot", systemImage: "list.bullet")) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(dish.name)
                            .font(.title2)
                            .bold()
                        
                        Text("Komponentit:")
                            .font(.headline)
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
                            .padding(.vertical, 2)
                        }
                        
                        if !dish.instructions.isEmpty {
                            Text("Valmistusohje:")
                                .font(.headline)
                                .padding(.top)
                            Text(dish.instructions)
                                .padding(.leading)
                        }
                    }
                    .padding()
                }
                
                // Delete button at bottom
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Poista annos")
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(dish.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: { showingEditSheet = true }) {
                Text("Muokkaa")
                    .foregroundColor(.brown)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditDishView(dish: dish)
        }
        .confirmationDialog(
            "Haluatko varmasti poistaa annoksen?",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Poista", role: .destructive) {
                deleteDish()
            }
            Button("Peruuta", role: .cancel) { }
        } message: {
            Text("Tätä toimintoa ei voi kumota")
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
