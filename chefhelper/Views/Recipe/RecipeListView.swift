import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]
    @State private var isAddingRecipe = false
    
    var body: some View {
        NavigationView {
            List {
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
            }
            .navigationTitle("Reseptit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: { isAddingRecipe = true }) {
                    Label("Lisää resepti", systemImage: "plus")
                        .foregroundColor(.brown)
                }
            }
            .sheet(isPresented: $isAddingRecipe) {
                AddRecipeView()
            }
        }
    }
    
    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipes[index])
        }
    }
} 