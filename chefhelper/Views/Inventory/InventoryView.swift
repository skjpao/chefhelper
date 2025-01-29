import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [InventoryItem]
    @State private var selectedCategory: Category = .all
    @State private var showingAddSheet = false
    @State private var showingSettings = false
    @State private var selectedTab = 0
    
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
                // Varaston arvo -palkki
                HStack {
                    Text("inventory_value".localized)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f €", totalValue))
                        .font(.headline)
                        .foregroundColor(.brown)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.brown.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Tab selection
                Picker("", selection: $selectedTab) {
                    Text("inventory".localized).tag(0)
                    Text("expiring_products".localized).tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 20)
                
                if selectedTab == 0 {
                    // Kategoria-valitsin
                    Picker("category".localized, selection: $selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.localizedName).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .padding(.horizontal)
                    
                    
                    // Regular inventory list
                    List {
                        if filteredItems.isEmpty {
                            Text("no_items".localized)
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
                } else {
                    // Expiration view
                    let itemsWithExpiry = items.filter { $0.expirationDate != nil }
                    if itemsWithExpiry.isEmpty {
                        Text("no_items".localized)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                            .padding(.top, 20)
                    } else {
                        ExpirationWarningView(items: itemsWithExpiry)
                    }
                    Spacer()
                }
            }
            .navigationTitle("inventory".localized)                    
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.brown)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.brown)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                NavigationStack {
                    AddInventoryItemView()
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
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
