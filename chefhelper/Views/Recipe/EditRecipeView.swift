import SwiftUI
import SwiftData

struct EditRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
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
        NavigationView {
            Form {
                Section(header: Text("Reseptin nimi")) {
                    TextField("Nimi", text: $name)
                }
                
                Section(header: Text("Ainesosat")) {
                    ForEach(ingredients) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Text("\(formatAmount(ingredient.amount)) \(ingredient.unit)")
                        }
                    }
                    .onDelete(perform: deleteIngredient)
                    
                    HStack {
                        TextField("Nimi", text: $newIngredientName)
                        TextField("Määrä", text: $newIngredientAmount)
                            .keyboardType(.decimalPad)
                        Picker("Yksikkö", selection: $selectedUnit) {
                            ForEach(RecipeUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                    }
                    
                    Button("Lisää ainesosa", action: addIngredient)
                }
                
                Section(header: Text("Ohjeet")) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Muokkaa reseptiä")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") { saveRecipe() }
                }
            }
            .alert("Virhe", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
    
    private func addIngredient() {
        guard !newIngredientName.isEmpty else {
            alertMessage = "Syötä ainesosan nimi"
            showingAlert = true
            return
        }
        
        guard let amount = Double(newIngredientAmount.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Syötä määrä numeroina"
            showingAlert = true
            return
        }
        
        let ingredient = RecipeIngredient(
            name: newIngredientName,
            amount: amount,
            unit: selectedUnit.rawValue
        )
        
        ingredients.append(ingredient)
        newIngredientName = ""
        newIngredientAmount = ""
        selectedUnit = .g
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    private func saveRecipe() {
        guard !name.isEmpty else {
            alertMessage = "Syötä reseptin nimi"
            showingAlert = true
            return
        }
        
        guard !ingredients.isEmpty else {
            alertMessage = "Lisää vähintään yksi ainesosa"
            showingAlert = true
            return
        }
        
        recipe.name = name
        recipe.ingredients = ingredients
        recipe.instructions = instructions
        
        dismiss()
    }
} 