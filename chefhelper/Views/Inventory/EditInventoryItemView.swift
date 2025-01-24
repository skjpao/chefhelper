import SwiftUI
import SwiftData

struct EditInventoryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: InventoryItem
    
    @State private var name: String
    @State private var amount: String
    @State private var selectedUnit: Unit
    @State private var selectedCategory: Category
    @State private var arrivalDate: Date
    @State private var expiryDate: Date?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(item: InventoryItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _amount = State(initialValue: String(item.amount))
        _selectedUnit = State(initialValue: item.unit)
        _selectedCategory = State(initialValue: item.category)
        _arrivalDate = State(initialValue: item.arrivalDate)
        _expiryDate = State(initialValue: item.expiryDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ainesosan tiedot")) {
                    TextField("Nimi", text: $name)
                    
                    Picker("Kategoria", selection: $selectedCategory) {
                        ForEach(Category.addCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    HStack {
                        TextField("Määrä", text: $amount)
                            .keyboardType(.decimalPad)
                        
                        Picker("Yksikkö", selection: $selectedUnit) {
                            ForEach([Unit.kg, .l, .pieces], id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section(header: Text("Päivämäärät")) {
                    DatePicker(
                        "Saapumispäivä",
                        selection: $arrivalDate,
                        displayedComponents: .date
                    )
                    
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
            .navigationTitle("Muokkaa ainesosaa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tallenna") {
                        saveChanges()
                    }
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
            alertMessage = "Syötä ainesosan nimi"
            showingAlert = true
            return
        }
        
        guard let amountValue = Double(amount) else {
            alertMessage = "Syötä määrä numeroina"
            showingAlert = true
            return
        }
        
        item.name = name
        item.amount = amountValue
        item.unit = selectedUnit
        item.category = selectedCategory
        item.arrivalDate = arrivalDate
        item.expiryDate = selectedCategory == .fresh ? expiryDate : nil
        
        dismiss()
    }
}