import SwiftUI
import SwiftData

struct AddInventoryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var amount = ""
    @State private var selectedUnit = InventoryUnit.kg
    @State private var selectedCategory = Category.fresh
    @State private var pricePerUnit = ""
    @State private var hasExpiryDate = false
    @State private var expiryDate = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private var datePicker: some View {
        DatePicker("", selection: Binding(
            get: { expiryDate },
            set: { 
                expiryDate = $0
            }
        ), displayedComponents: .date)
        .labelsHidden()
    }
    
    var body: some View {
        Form {
            Section(header: Text("item_details".localized)) {
                HStack {
                    Text("name".localized)
                        .foregroundColor(.brown)
                    Spacer()
                    TextField("item_name".localized, text: $name)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("category".localized)
                        .foregroundColor(.brown)
                    Spacer()
                    categoryPicker
                }
                
                HStack {
                    Text("amount".localized)
                        .foregroundColor(.brown)
                    Spacer()
                    TextField("amount".localized, text: $amount)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("unit".localized)
                        .foregroundColor(.brown)
                    Spacer()
                    unitPicker
                }
                
                HStack {
                    Text("price".localized)
                        .foregroundColor(.brown)
                    Spacer()
                    TextField("enter_price".localized, text: $pricePerUnit)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                
                if selectedCategory == .fresh {
                    Toggle(isOn: $hasExpiryDate) {
                        Text("expiry_date".localized)
                            .foregroundColor(.brown)
                    }
                    
                    if hasExpiryDate {
                        HStack {
                            Text("select_date".localized)
                                .foregroundColor(.brown)
                            Spacer()
                            datePicker
                        }
                    }
                }
            }
        }
        .navigationTitle("new_item".localized)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button(action: { dismiss() }) {
                    Text("cancel".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown.opacity(0.1))
                        .foregroundColor(.brown)
                        .cornerRadius(8)
                }
                Button(action: addItem) {
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
        .alert("error".localized, isPresented: $showingAlert) {
            Button("ok".localized, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var categoryPicker: some View {
        Picker("", selection: $selectedCategory) {
            ForEach([Category.fresh, .dry, .misc], id: \.self) { category in
                Text(category.localizedName)
                    .tag(category)
                    .foregroundColor(.primary)
            }
        }
        .tint(.primary)
        .labelsHidden()
    }
    
    private var unitPicker: some View {
        Picker("", selection: $selectedUnit) {
            ForEach(InventoryUnit.allCases, id: \.self) { unit in
                Text(unit.localizedName)
                    .tag(unit)
                    .foregroundColor(.primary)
            }
        }
        .tint(.primary)
        .labelsHidden()
    }
    
    private func addItem() {
        guard !name.isEmpty else {
            alertMessage = "enter_item_name".localized
            showingAlert = true
            return
        }
        
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "enter_amount".localized
            showingAlert = true
            return
        }
        
        guard let priceValue = Double(pricePerUnit.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "enter_price".localized
            showingAlert = true
            return
        }
        
        let item = InventoryItem(
            name: name,
            amount: amountValue,
            unit: selectedUnit,
            category: selectedCategory,
            pricePerUnit: priceValue,
            expirationDate: hasExpiryDate ? Calendar.current.startOfDay(for: expiryDate) : nil
        )
        
        print("Creating new item:")
        print("Name: \(item.name)")
        print("Amount: \(item.amount) \(item.unit.rawValue)")
        print("Category: \(item.category.rawValue)")
        print("Price: \(item.pricePerUnit)")
        print("Expiration: \(String(describing: item.expirationDate))")
        
        modelContext.insert(item)
        
        do {
            try modelContext.save()
            print("Item saved successfully")
            dismiss()
        } catch {
            print("Failed to save item: \(error)")
            alertMessage = "save_error".localized
            showingAlert = true
        }
    }
}
