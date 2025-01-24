import SwiftUI
import SwiftData

struct AddInventoryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var amount = ""
    @State private var selectedUnit: Unit = .kg
    @State private var selectedCategory: Category = .fresh
    @State private var arrivalDate = Date()
    @State private var expiryDate: Date? = nil
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tuotteen tiedot")) {
                    TextField("Nimi", text: $name)
                    
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

                    Picker("Kategoria", selection: $selectedCategory) {
                        ForEach(Category.addCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
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
            .navigationTitle("Lisää tuote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Peruuta") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lisää") {
                        addItem()
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
    
    private func addItem() {
        guard !name.isEmpty else {
            alertMessage = "Syötä tuotteen nimi"
            showingAlert = true
            return
        }
        
        guard let amountValue = Double(amount) else {
            alertMessage = "Syötä määrä numeroina"
            showingAlert = true
            return
        }
        
        let item = InventoryItem(
            name: name,
            amount: amountValue,
            unit: selectedUnit,
            category: selectedCategory,
            arrivalDate: arrivalDate,
            expiryDate: selectedCategory == .fresh ? expiryDate : nil
        )
        
        // Add debug print to verify item creation
        print("Adding item: \(item.name) with amount: \(item.amount) \(item.unit.rawValue)")
        
        // Explicitly insert into model context
        modelContext.insert(item)
        
        do {
            try modelContext.save()
            print("Item saved successfully")
        } catch {
            print("Failed to save item: \(error)")
            alertMessage = "Virhe tallennuksessa: \(error.localizedDescription)"
            showingAlert = true
            return
        }
        
        dismiss()
    }
}