import SwiftUI
import SwiftData

struct AddComponentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var components: [DishComponent]
    let isEmbedded: Bool
    let dismissAfterAdd: Bool
    
    @State private var name = ""
    @State private var amount = ""
    @State private var selectedUnit: RecipeUnit = .g
    @State private var selectedRecipe: Recipe?
    @State private var showingRecipePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(components: Binding<[DishComponent]>, isEmbedded: Bool = false, dismissAfterAdd: Bool = false) {
        self._components = components
        self.isEmbedded = isEmbedded
        self.dismissAfterAdd = dismissAfterAdd
    }
    
    var body: some View {
        Form {
            Section {
                // Komponentti suoraan tai reseptistä
                Button("select_from_recipes".localized) {
                    showingRecipePicker = true
                }
                
                // Manuaalinen lisäys
                TextField("component_name".localized, text: $name)
                
                HStack {
                    TextField("amount".localized, text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("unit".localized, selection: $selectedUnit) {
                        ForEach(RecipeUnit.allCases, id: \.self) { unit in
                            Text(unit.localizedName).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
        .navigationTitle("add_component".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingRecipePicker) {
            NavigationStack {
                RecipePickerView(components: $components)
            }
        }
        .alert("error".localized, isPresented: $showingAlert) {
            Button("ok".localized, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        HStack {
            Button(action: { dismiss() }) {
                Text("cancel".localized)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brown.opacity(0.1))
                    .foregroundColor(.brown)
                    .cornerRadius(8)
            }
            Button(action: addComponent) {
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
    
    private func addComponent() {
        guard !name.isEmpty else {
            alertMessage = "enter_component_name".localized
            showingAlert = true
            return
        }
        
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "enter_amount".localized
            showingAlert = true
            return
        }
        
        let component = DishComponent(
            name: name,
            amount: amountValue,
            unit: selectedUnit
        )
        
        components.append(component)
        
        if dismissAfterAdd {
            dismiss()
        } else {
            // Tyhjennä kentät uutta komponenttia varten
            name = ""
            amount = ""
        }
    }
} 
