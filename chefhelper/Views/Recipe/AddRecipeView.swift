import SwiftUI
import SwiftData

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var inventoryItems: [InventoryItem]
    
    @State private var name = ""
    @State private var ingredients: [Ingredient] = []
    @State private var newIngredientName = ""
    @State private var newIngredientAmount = ""
    @State private var instructions = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSuggestions = false
    @State private var selectedCategory: Category = .misc
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Reseptin nimi")) {
                        TextField("Nimi", text: $name)
                    }
                    
                    Section(header: Text("Ainesosat")) {
                        VStack(spacing: 10) {
                            TextField("Ainesosan nimi", text: $newIngredientName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: newIngredientName) { _, newValue in
                                    showingSuggestions = !newValue.isEmpty
                                }
                            
                            if showingSuggestions {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(inventoryItems.filter {
                                            $0.name.lowercased().contains(newIngredientName.lowercased())
                                        }) { item in
                                            Button(action: {
                                                selectInventoryItem(item)
                                            }) {
                                                VStack(alignment: .leading) {
                                                    Text(item.name)
                                                        .foregroundColor(.brown)
                                                    Text(item.category.rawValue)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color.brown.opacity(0.1))
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            
                            TextField("Määrä (g)", text: $newIngredientAmount)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            
                            Button(action: addIngredient) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Lisää ainesosa")
                                }
                                .foregroundColor(.brown)
                            }
                            .buttonStyle(.bordered)
                            .tint(.brown)
                            .padding(.vertical, 5)
                        }
                        .padding(.vertical, 8)
                        
                        if !ingredients.isEmpty {
                            ForEach(ingredients) { ingredient in
                                HStack {
                                    Text("\(ingredient.name): \(String(format: "%.1f", ingredient.amount))g")
                                        .foregroundColor(.brown)
                                    Spacer()
                                    Button(action: { deleteIngredient(ingredient) }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Ohjeet")) {
                        TextEditor(text: $instructions)
                            .frame(minHeight: 150)
                    }
                }
                
                // Bottom buttons with rustic styling
                VStack(spacing: 10) {
                    Button(action: saveRecipe) {
                        Text("Tallenna resepti")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Peruuta")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brown.opacity(0.1))
                            .foregroundColor(.brown)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Uusi resepti")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Virhe", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addIngredient() {
        guard !newIngredientName.isEmpty else {
            alertMessage = "Syötä ainesosan nimi"
            showingAlert = true
            return
        }
        
        guard let amount = Double(newIngredientAmount) else {
            alertMessage = "Syötä määrä numeroina"
            showingAlert = true
            return
        }
        
        ingredients.append(Ingredient(
            name: newIngredientName, 
            amount: amount,
            unit: .kg, // Always use kg (grams)
            category: selectedCategory
        ))
        newIngredientName = ""
        newIngredientAmount = ""
    }
    
    private func deleteIngredient(_ ingredient: Ingredient) {
        ingredients.removeAll { $0.name == ingredient.name }
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
        
        let recipe = Recipe(name: name, ingredients: ingredients, instructions: instructions)
        modelContext.insert(recipe)
        dismiss()
    }
    
    private func selectInventoryItem(_ item: InventoryItem) {
        newIngredientName = item.name
        selectedCategory = item.category
        // Convert the inventory amount to grams if needed
        if item.unit == .kg {
            newIngredientAmount = String(item.amount * 1000) // Convert kg to g
        } else if item.unit == .l {
            // For liquids, assume 1L = 1000g (approximate)
            newIngredientAmount = String(item.amount * 1000)
        } else {
            // For pieces, leave empty for manual input
            newIngredientAmount = ""
        }
        showingSuggestions = false
    }
} 