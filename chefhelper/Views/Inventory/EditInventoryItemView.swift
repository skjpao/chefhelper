import SwiftUI
import SwiftData

struct EditInventoryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: InventoryItem
    
    @State private var name: String
    @State private var amount: String
    @State private var selectedUnit: InventoryUnit
    @State private var pricePerUnit: String
    @State private var selectedCategory: Category
    @State private var expiryDate: Date?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(item: InventoryItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _amount = State(initialValue: String(item.amount))
        _selectedUnit = State(initialValue: item.unit)
        _pricePerUnit = State(initialValue: String(item.pricePerUnit))
        _selectedCategory = State(initialValue: item.category)
        _expiryDate = State(initialValue: item.expirationDate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tuotteen tiedot")) {
                    TextField("Nimi", text: $name)
                    
                    HStack {
                        TextField("Määrä", text: $amount)
                            .keyboardType(.decimalPad)
                        
                        Picker("Yksikkö", selection: $selectedUnit) {
                            ForEach(InventoryUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    TextField("Hinta/\(selectedUnit.rawValue)", text: $pricePerUnit)
                        .keyboardType(.decimalPad)
                    
                    Picker("Kategoria", selection: $selectedCategory) {
                        ForEach(Category.addCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Päivämäärät")) {
                    if selectedCategory == .fresh {
                        Toggle("Viimeinen käyttöpäivä", isOn: Binding(
                            get: { expiryDate != nil },
                            set: { if !$0 { expiryDate = nil } else { expiryDate = Date() } }
                        ))
                        
                        if expiryDate != nil {
                            DatePicker(
                                "Viimeinen käyttöpäivä",
                                selection: Binding(
                                    get: { expiryDate ?? Date() },
                                    set: { expiryDate = $0 }
                                ),
                                displayedComponents: .date
                            )
                        }
                    }
                }
            }
            .navigationTitle("Muokkaa tuotetta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") { saveChanges() }
                }
            }
            .alert("Virhe", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveChanges() {
        guard !name.isEmpty else {
            alertMessage = "Syötä tuotteen nimi"
            showingAlert = true
            return
        }
        
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Syötä määrä numeroina"
            showingAlert = true
            return
        }
        
        guard let price = Double(pricePerUnit.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Syötä hinta numeroina"
            showingAlert = true
            return
        }
        
        item.name = name
        item.amount = amountValue
        item.unit = selectedUnit
        item.pricePerUnit = price
        item.category = selectedCategory
        item.expirationDate = expiryDate
        item.updatedAt = Date()
        
        dismiss()
    }
}
