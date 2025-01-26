import SwiftUI
import SwiftData

struct AddComponentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    @Binding var components: [DishComponent]
    let isEmbedded: Bool
    
    @State private var name = ""
    @State private var amount = ""
    @State private var selectedUnit: RecipeUnit = .g
    @State private var selectedRecipe: Recipe?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var searchText = ""
    
    init(components: Binding<[DishComponent]>, isEmbedded: Bool = false) {
        self._components = components
        self.isEmbedded = isEmbedded
    }
    
    var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return recipes
        }
        return recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        let mainContent = Form {
            Section {
                TextField("Nimi", text: $name)
                
                HStack {
                    TextField("Määrä", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Yksikkö", selection: $selectedUnit) {
                        ForEach(RecipeUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            Section(header: Text("Linkitä reseptiin (valinnainen)")) {
                TextField("Hae reseptiä...", text: $searchText)
                
                ForEach(filteredRecipes) { recipe in
                    HStack {
                        Text(recipe.name)
                        Spacer()
                        if selectedRecipe?.id == recipe.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedRecipe?.id == recipe.id {
                            selectedRecipe = nil
                            name = ""
                        } else {
                            selectedRecipe = recipe
                            name = recipe.name
                        }
                    }
                }
            }
        }
        .navigationTitle("Lisää komponentti")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Peruuta") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Lisää") { addComponent() }
            }
        }
        .alert("Virhe", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        
        if isEmbedded {
            mainContent
        } else {
            NavigationStack {
                mainContent
            }
        }
    }
    
    private func addComponent() {
        guard !name.isEmpty else {
            alertMessage = "Syötä komponentin nimi"
            showingAlert = true
            return
        }
        
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Syötä määrä numeroina"
            showingAlert = true
            return
        }
        
        let component = DishComponent(
            name: name,
            amount: amountValue,
            unit: selectedUnit,
            recipe: selectedRecipe
        )
        
        components.append(component)
        dismiss()
    }
} 