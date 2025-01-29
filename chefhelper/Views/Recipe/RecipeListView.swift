import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    @Query(sort: \Dish.name) private var dishes: [Dish]
    @State private var selectedTab = 0
    @State private var showingAddSheet = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("view".localized, selection: $selectedTab) {
                    Text("recipes".localized).tag(0)
                    Text("dishes".localized).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.brown.opacity(0.1))
                
                List {
                    if selectedTab == 0 {
                        if recipes.isEmpty {
                            Text("no_recipes".localized)
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
                                        Text("\(recipe.ingredients.count) \("ingredients".localized)")
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
                            Text("no_dishes".localized)
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
                                        Text("\(dish.components.count) \("components".localized)")
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
            .navigationTitle(selectedTab == 0 ? "recipes".localized : "dishes".localized)
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
            .sheet(isPresented: $showingSettings) {
                SettingsView()
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
