import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var recipe: Recipe
    
    @State private var newComment = ""
    @State private var scalingFactor = "1.0"
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Recipe details section
                GroupBox(label: Label("recipe_details".localized, systemImage: "list.bullet")) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text(recipe.name)
                            .font(.title2)
                            .bold()
                        
                        Text("ingredients_title".localized + ":")
                            .font(.headline)
                        Section(header: Text("ingredients_title".localized)) {
                            let ingredients = recipe.ingredients
                            ForEach(ingredients) { ingredient in
                                HStack {
                                    Text(ingredient.name)
                                    Spacer()
                                    Text("\(formatAmount(ingredient.amount)) \(ingredient.unit)")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        Text("instructions_title".localized + ":")
                            .font(.headline)
                        Text(recipe.instructions)
                            .padding(.leading)
                    }
                    .padding()
                }
                
                // Scaling section
                GroupBox(label: Label("scaling".localized, systemImage: "arrow.up.right.and.arrow.down.left.rectangle")) {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("scaling_factor".localized, text: $scalingFactor)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let factor = Double(scalingFactor), factor > 0 {
                            let scaledIngredients = recipe.ingredients
                            ForEach(scaledIngredients) { ingredient in
                                Text("• \(ingredient.name): \(String(format: "%.1f", ingredient.amount * factor))\(ingredient.unit)")
                            }
                            .padding(.leading)
                        }
                    }
                    .padding()
                }
                
                // Comments section
                GroupBox(label: Label("comments".localized, systemImage: "text.bubble")) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(recipe.comments.enumerated()), id: \.element) { index, comment in
                            HStack {
                                Text("• \(comment)")
                                Spacer()
                                Button(action: { deleteComment(at: index) }) {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        HStack {
                            TextField("add_comment".localized, text: $newComment)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: addComment) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.brown)
                            }
                        }
                    }
                    .padding()
                }
                
                // Delete button
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("delete_recipe".localized)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle(recipe.name)
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
    
    private func deleteComment(at index: Int) {
        recipe.comments.remove(at: index)
    }
    
    private func deleteRecipe() {
        modelContext.delete(recipe)
        dismiss()
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
} 
