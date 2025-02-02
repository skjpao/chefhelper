import SwiftUI
import SwiftData

struct EditRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var inventoryItems: [InventoryItem]
    @Bindable var recipe: Recipe
    
    @State private var name: String
    @State private var ingredients: [RecipeIngredient]
    @State private var instructions: String
    @State private var newIngredientName = ""
    @State private var newIngredientAmount = ""
    @State private var selectedUnit: RecipeUnit = .g
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _name = State(initialValue: recipe.name)
        _ingredients = State(initialValue: recipe.ingredients)
        _instructions = State(initialValue: recipe.instructions)
    }
    
    var body: some View {
            Form {
                Section(header: Text("recipe_name".localized)) {
                    TextField("recipe_name".localized, text: $name)
                }
                
                Section(header: Text("ingredients_title".localized)) {
                    ForEach(ingredients) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Text("\(formatAmount(ingredient.amount)) \(ingredient.unit)")
                        }
                    }
                    .onDelete(perform: deleteIngredient)
                    
                    HStack {
                        TextField("enter_ingredient_name".localized, text: $newIngredientName)
                        TextField("enter_amount".localized, text: $newIngredientAmount)
                            .keyboardType(.decimalPad)
                        Picker("unit".localized, selection: $selectedUnit) {
                            ForEach(RecipeUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                    }
                    
                    Button("add_ingredient".localized) {
                        addIngredient()
                    }
                }
                
                Section(header: Text("instructions_title".localized)) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("edit_recipe".localized)
            .navigationBarTitleDisplayMode(.inline)
            .alert("error".localized, isPresented: $showingAlert) {
                Button("ok".localized, role: .cancel) { }
            } message: {
                Text(alertMessage)
            }

                        // Tallenna/Peruuta napit
            HStack {
                Button(action: { dismiss() }) {
                    Text("cancel".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown.opacity(0.1))
                        .foregroundColor(.brown)
                        .cornerRadius(8)
                }
                Button(action: saveRecipe) {
                    Text("save".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
    
    private func addIngredient() {
        guard let amount = Double(newIngredientAmount.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let ingredient = RecipeIngredient(
            name: newIngredientName,
            amount: amount,
            unit: selectedUnit,
            inventoryItem: inventoryItems.first { $0.name == newIngredientName }
        )
        
        recipe.ingredients.append(ingredient)
        newIngredientName = ""
        newIngredientAmount = ""
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    private func saveRecipe() {
        guard !name.isEmpty else {
            alertMessage = "enter_recipe_name".localized
            showingAlert = true
            return
        }
        
        guard !ingredients.isEmpty else {
            alertMessage = "add_at_least_one_ingredient".localized
            showingAlert = true
            return
        }
        
        recipe.name = name
        recipe.ingredients = ingredients
        recipe.instructions = instructions
        
        dismiss()
    }
} 