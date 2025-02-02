import SwiftUI
import SwiftData

struct RecipePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    @Binding var components: [DishComponent]
    @State private var selectedRecipe: Recipe?
    @State private var amount = ""
    @State private var selectedUnit: RecipeUnit = .g
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            if selectedRecipe != nil {
                AmountSection(amount: $amount, unit: $selectedUnit)
            }
            
            RecipeListSection(
                recipes: recipes,
                selectedRecipe: $selectedRecipe
            )
        }
        .navigationTitle("select_recipe".localized)
        .toolbar {
            if selectedRecipe != nil {
                Button("add".localized) {
                    addComponent()
                }
            }
        }
        .alert("error".localized, isPresented: $showingAlert) {
            Button("ok".localized, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func addComponent() {
        guard let recipe = selectedRecipe else { return }
        
        // Tarkistetaan että määrä on kelvollinen numero
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "enter_amount".localized
            showingAlert = true
            return
        }
        
        let component = DishComponent(
            name: recipe.name,
            amount: amountValue,
            unit: selectedUnit,
            recipe: recipe
        )
        
        components.append(component)
        dismiss() // Suljetaan näkymä heti komponentin lisäämisen jälkeen
    }
}

private struct AmountSection: View {
    @Binding var amount: String
    @Binding var unit: RecipeUnit
    
    var body: some View {
        Section {
            HStack {
                TextField("amount".localized, text: $amount)
                    .keyboardType(.decimalPad)
                
                Picker("unit".localized, selection: $unit) {
                    ForEach(RecipeUnit.allCases, id: \.self) { unit in
                        Text(unit.localizedName).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

private struct RecipeListSection: View {
    let recipes: [Recipe]
    @Binding var selectedRecipe: Recipe?
    
    var body: some View {
        Section {
            ForEach(recipes) { recipe in
                RecipeRow(
                    recipe: recipe,
                    isSelected: recipe.id == selectedRecipe?.id
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedRecipe = recipe
                }
            }
        }
    }
}

private struct RecipeRow: View {
    let recipe: Recipe
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.headline)
                Text("\(recipe.ingredients.count) \("ingredients".localized)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.brown)
            }
        }
    }
} 
