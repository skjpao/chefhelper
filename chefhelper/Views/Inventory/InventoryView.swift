import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InventoryItem.name) private var inventoryItems: [InventoryItem]
    @State private var showingAddSheet = false
    @State private var selectedTab: Category = .all
    @State private var itemToEdit: InventoryItem?
    
    var filteredItems: [InventoryItem] {
        switch selectedTab {
        case .all:
            return inventoryItems.sorted { $0.name < $1.name }
        case .fresh, .dry, .misc:
            return inventoryItems.filter { $0.category == selectedTab }
                       .sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Kategoria", selection: $selectedTab) {
                    ForEach(Category.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.brown.opacity(0.1))
                
                List {
                    // Otsikkorivi
                    HStack(spacing: 8) {
                        Text("Nimi")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.brown)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if selectedTab == .fresh {
                            Text("Saapunut")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.brown)
                                .fontWeight(.medium)
                                .frame(width: 80)
                            
                            Text("VKP")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.brown)
                                .fontWeight(.medium)
                                .frame(width: 80)
                        } else {
                            Spacer()
                            Text("Saapunut")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.brown)
                                .fontWeight(.medium)
                                .frame(width: 80)
                            Spacer()
                        }
                        
                        Text("Määrä")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.brown)
                            .fontWeight(.medium)
                            .frame(width: 94)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.brown.opacity(0.1))

                    if filteredItems.isEmpty {
                        Text("Ei ainesosia")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredItems) { item in
                            InventoryItemRow(
                                item: item,
                                showExpiryDate: selectedTab == .fresh
                            )
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Varasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: { showingAddSheet = true }) {
                    Label("Lisää ainesosa", systemImage: "plus")
                        .foregroundColor(.brown)
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddInventoryItemView()
            }
            .sheet(item: $itemToEdit) { item in
                EditInventoryItemView(item: item)
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(inventoryItems[index])
        }
    }
} 
