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
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var hasExpiryDate: Bool
    
    init(item: InventoryItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _amount = State(initialValue: String(item.amount))
        _selectedUnit = State(initialValue: item.unit)
        _pricePerUnit = State(initialValue: String(item.pricePerUnit))
        _selectedCategory = State(initialValue: item.category)
        _hasExpiryDate = State(initialValue: item.expirationDate != nil)
    }
    
    private var categoryPicker: some View {
        Picker("", selection: $item.category) {
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
        Picker("", selection: $item.unit) {
            ForEach(InventoryUnit.allCases, id: \.self) { unit in
                Text(unit.localizedName)
                    .tag(unit)
                    .foregroundColor(.primary)
            }
        }
        .tint(.primary)
        .labelsHidden()
    }
    
    private var expirationDateBinding: Binding<Date> {
        Binding(
            get: { item.expirationDate ?? Date() },
            set: { 
                if hasExpiryDate {
                    let calendar = Calendar.current
                    item.expirationDate = calendar.startOfDay(for: $0)
                } else {
                    item.expirationDate = nil
                }
            }
        )
    }
    
    var body: some View {
        Form {
            Section(header: Text("item_details".localized)) {
                HStack {
                    Text("name".localized)
                        .foregroundColor(.brown)
                    Spacer()
                    TextField("item_name".localized, text: $item.name)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("category".localized)
                        .foregroundColor(.brown)
                    Spacer()
                    categoryPicker
                }
                
                HStack {
                    Text("price".localized)
                        .foregroundColor(.brown)
                    Spacer()
                    TextField("enter_price".localized, text: $pricePerUnit)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("unit".localized)
                        .foregroundColor(.brown)
                    Spacer()
                    unitPicker
                }
                
                if item.category == .fresh {
                    Toggle(isOn: $hasExpiryDate) {
                        Text("expiry_date".localized)
                            .foregroundColor(.brown)
                    }
                    
                    if hasExpiryDate {
                        HStack {
                            Text("select_date".localized)
                                .foregroundColor(.brown)
                            Spacer()
                            DatePicker("", selection: expirationDateBinding, displayedComponents: .date)
                            .labelsHidden()
                        }
                    }
                }
            }
        }
        .navigationTitle("edit_item".localized)
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
                Button(action: saveChanges) {
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
    }
    
    private func saveChanges() {
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
        
        guard let price = Double(pricePerUnit.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "enter_price".localized
            showingAlert = true
            return
        }
        
        item.name = name
        item.amount = amountValue
        item.unit = selectedUnit
        item.pricePerUnit = price
        item.category = selectedCategory
        item.updatedAt = Date()
        
        dismiss()
    }
}
