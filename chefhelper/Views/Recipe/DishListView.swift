import SwiftUI
import SwiftData

struct DishListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Dish.name) private var dishes: [Dish]
    @State private var showingAddSheet = false
    @State private var searchText = ""
    
    var filteredDishes: [Dish] {
        if searchText.isEmpty {
            return dishes
        }
        return dishes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            SearchBarView(text: $searchText)
            
            ForEach(filteredDishes) { dish in
                NavigationLink(destination: DishDetailView(dish: dish)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dish.name)
                            .font(.headline)
                    }
                }
            }
            .onDelete(perform: deleteDishes)
        }
        .navigationTitle("Annokset")
        .toolbar {
            Button(action: { showingAddSheet = true }) {
                Label("Lisää annos", systemImage: "plus")
                    .foregroundColor(.brown)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddDishView()
        }
    }
    
    private func deleteDishes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(dishes[index])
        }
    }
} 