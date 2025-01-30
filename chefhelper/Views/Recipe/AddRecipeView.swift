import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var inventoryItems: [InventoryItem]
    
    @State private var name = ""
    @State private var ingredients: [RecipeIngredient] = []
    @State private var newIngredientName = ""
    @State private var newIngredientAmount = ""
    @State private var instructions = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSuggestions = false
    @State private var selectedCategory: Category = .misc
    @State private var selectedUnit: RecipeUnit = .g
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("recipe_name".localized)) {
                    TextField("recipe_name".localized, text: $name)
                }
                
                Section(header: Text("ingredients_title".localized)) {
                    ingredientForm
                    
                    if !ingredients.isEmpty {
                        Divider()
                            .padding(.vertical, 8)
                        
                        ForEach(ingredients) { ingredient in
                            HStack {
                                Text(ingredient.name)
                                Spacer()
                                Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit.localizedName)")
                                    .foregroundColor(.gray)
                                Button(action: { deleteIngredient(ingredient) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section(header: Text("instructions_title".localized)) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 150)
                }
            }
            
            // Bottom buttons with rustic styling
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
        .navigationTitle("new_recipe".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert("error".localized, isPresented: $showingAlert) {
            Button("ok".localized, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var ingredientForm: some View {
        VStack(spacing: 16) {
            // Ainesosan nimi
            TextField("enter_ingredient_name".localized, text: $newIngredientName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                // Määrä
                TextField("amount".localized, text: $newIngredientAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Yksikkö
                Picker("", selection: $selectedUnit) {
                    ForEach(RecipeUnit.allCases, id: \.self) { unit in
                        Text(unit.localizedName).tag(unit)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Button(action: addIngredient) {
                Text("add_ingredient".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(newIngredientName.isEmpty || newIngredientAmount.isEmpty)
        }
        .padding()
    }
    
    private func addIngredient() {
        guard let amount = Double(newIngredientAmount.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let ingredient = RecipeIngredient(
            name: newIngredientName,
            amount: amount,
            unit: selectedUnit,
            inventoryItem: inventoryItems.first { $0.name == newIngredientName }
        )
        
        ingredients.append(ingredient)
        newIngredientName = ""
        newIngredientAmount = ""
    }
    
    private func deleteIngredient(_ ingredient: RecipeIngredient) {
        ingredients.removeAll { $0.name == ingredient.name }
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
        
        let recipe = Recipe(
            name: name,
            ingredients: ingredients,
            instructions: instructions
        )
        modelContext.insert(recipe)
        dismiss()
    }
    
    private func selectInventoryItem(_ item: InventoryItem) {
        newIngredientName = item.name
        selectedCategory = item.category
        // Convert the inventory amount to recipe units
        if item.unit == .kg {
            newIngredientAmount = String(item.amount * 1000) // kg -> g
        } else if item.unit == .l {
            newIngredientAmount = String(item.amount * 10) // l -> dl
        } else {
            newIngredientAmount = String(item.amount) // kpl -> kpl
        }
        showingSuggestions = false
    }
}
