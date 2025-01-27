import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [InventoryItem]
    @State private var selectedCategory: Category = .all
    @State private var showingAddSheet = false
    
    var filteredItems: [InventoryItem] {
        if selectedCategory == .all {
            return items
        }
        return items.filter { $0.category == selectedCategory }
    }
    
    var totalValue: Double {
        items.reduce(0) { $0 + $1.totalValue }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Varaston kokonaisarvo
                GroupBox {
                    HStack {
                        Text("Varaston arvo:")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f €", totalValue))
                            .font(.headline)
                            .foregroundColor(.brown)
                    }
                }
                .padding()
                
                // Kategoria-valitsin
                Picker("Kategoria", selection: $selectedCategory) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Lista tuotteista
                List {
                    if filteredItems.isEmpty {
                        Text("Ei tuotteita")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredItems) { item in
                            NavigationLink(destination: EditInventoryItemView(item: item)) {
                                InventoryItemRow(item: item)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Varasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    AddInventoryItemView()
                }
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredItems[index])
        }
        try? modelContext.save()
    }
}

struct ExpiryListView: View {
    let items: [InventoryItem]
    
    var body: some View {
        List {
            if items.isEmpty {
                Text("Ei vanhenevia tuotteita")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(items.sorted { $0.daysUntilExpiration ?? 0 < $1.daysUntilExpiration ?? 0 }) { item in
                    if let days = item.daysUntilExpiration {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text("\(days) päivää jäljellä")
                                    .font(.subheadline)
                                    .foregroundColor(days <= 3 ? .red : .orange)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(String(format: "%.1f %@", item.amount, item.unit.rawValue))
                                Text(String(format: "%.2f €", item.totalValue))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct ExpirationWarningView: View {
    let items: [InventoryItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Vanhenevat tuotteet:")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(items) { item in
                if let days = item.daysUntilExpiration {
                    Text("\(item.name) - \(days) päivää jäljellä")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.8))
    }
}
