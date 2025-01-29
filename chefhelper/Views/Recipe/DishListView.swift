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
            
            if dishes.isEmpty {
                ContentUnavailableView {
                    Label("no_dishes".localized, systemImage: "fork.knife")
                } description: {
                    Text("add_first_dish".localized)
                }
            } else {
                ForEach(filteredDishes) { dish in
                    NavigationLink(value: dish) {
                        VStack(alignment: .leading) {
                            Text(dish.name)
                                .font(.headline)
                            Text("\(dish.components.count) \("components".localized)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: deleteDishes)
            }
        }
        .navigationTitle("dishes".localized)
        .toolbar {
            Button(action: { showingAddSheet = true }) {
                Image(systemName: "plus")
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