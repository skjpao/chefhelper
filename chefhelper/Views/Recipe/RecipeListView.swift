import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    @Query(sort: \Dish.name) private var dishes: [Dish]
    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Näkymä", selection: $selectedTab) {
                    Text("Reseptit").tag(0)
                    Text("Annokset").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    if selectedTab == 0 {
                        if recipes.isEmpty {
                            Text("Ei reseptejä")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(recipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(recipe.name)
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(.brown)
                                        Text("\(recipe.ingredients.count) ainesosaa")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete(perform: deleteRecipes)
                        }
                    } else {
                        if dishes.isEmpty {
                            Text("Ei annoksia")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(dishes) { dish in
                                NavigationLink(destination: DishDetailView(dish: dish)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(dish.name)
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(.brown)
                                        Text("\(dish.components.count) komponenttia")
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete(perform: deleteDishes)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle(selectedTab == 0 ? "Reseptit" : "Annokset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                if selectedTab == 0 {
                    NavigationStack {
                        AddRecipeView()
                    }
                } else {
                    NavigationStack {
                        AddDishView()
                    }
                }
            }
        }
    }
    
    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipes[index])
        }
        try? modelContext.save()
    }
    
    private func deleteDishes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(dishes[index])
        }
        try? modelContext.save()
    }
} 