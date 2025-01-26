import SwiftUI
import SwiftData

struct RecipePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    @Binding var components: [DishComponent]
    @State private var amount = ""
    @State private var selectedUnit: RecipeUnit = .g
    @State private var selectedRecipe: Recipe?
    
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
        .navigationTitle("Valitse resepti")
        .toolbar {
            if selectedRecipe != nil {
                Button("Lisää") {
                    addComponent()
                }
            }
        }
    }
    
    private func addComponent() {
        if let recipe = selectedRecipe,
           let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) {
            let component = DishComponent(
                name: recipe.name,
                amount: amountValue,
                unit: selectedUnit,
                recipe: recipe
            )
            components.append(component)
        }
        dismiss()
    }
}

private struct AmountSection: View {
    @Binding var amount: String
    @Binding var unit: RecipeUnit
    
    var body: some View {
        Section {
            HStack {
                TextField("Määrä", text: $amount)
                    .keyboardType(.decimalPad)
                
                Picker("Yksikkö", selection: $unit) {
                    ForEach(RecipeUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
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
                Text("\(recipe.ingredients.count) raaka-ainetta")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
    }
} 
