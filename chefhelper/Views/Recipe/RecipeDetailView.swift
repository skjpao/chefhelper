import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var recipe: Recipe
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var newComment = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("recipe_details".localized)) {
                    Text(recipe.name)
                        .font(.headline)
                    
                    if recipe.portionSize > 1 {
                        Text("\(recipe.portionSize) \("portions".localized)")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("ingredients_title".localized)) {
                    if recipe.ingredients.isEmpty {
                        Text("no_ingredients".localized)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Text(ingredient.name)
                                Spacer()
                                Text("\(formatAmount(ingredient.amount)) \(ingredient.unit.rawValue)")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                if !recipe.instructions.isEmpty {
                    Section(header: Text("instructions_title".localized)) {
                        Text(recipe.instructions)
                    }
                }
                
                Section(header: Text("comments".localized)) {
                    ForEach(recipe.comments, id: \.self) { comment in
                        HStack {
                            Text(comment)
                            Spacer()
                            Button(action: { deleteComment(comment) }) {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("add_comment".localized, text: $newComment)
                        Button(action: addComment) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.brown)
                        }
                    }
                }
            }
            
            // Napit alalaidassa
            HStack {
                Button(action: { showingEditSheet = true }) {
                    Text("edit".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditRecipeView(recipe: recipe)
            }
        }
        .confirmationDialog(
            "delete_recipe_confirmation".localized,
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("delete".localized, role: .destructive) {
                deleteRecipe()
            }
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("cannot_undo".localized)
        }
    }
    
    private func addComment() {
        guard !newComment.isEmpty else { return }
        recipe.comments.append(newComment)
        newComment = ""
    }
    
    private func deleteComment(_ comment: String) {
        if let index = recipe.comments.firstIndex(of: comment) {
            recipe.comments.remove(at: index)
        }
    }
    
    private func deleteRecipe() {
        modelContext.delete(recipe)
        dismiss()
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
} 
