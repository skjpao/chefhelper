import SwiftUI
import SwiftData

struct DishDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var dish: Dish
    
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    
    var body: some View {
        Form {
            Section(header: Text("dish_details".localized)) {
                Text(dish.name)
                    .font(.headline)
            }
            
            Section(header: Text("components_title".localized)) {
                if dish.components.isEmpty {
                    Text("no_components".localized)
                        .foregroundColor(.gray)
                } else {
                    ForEach(dish.components) { component in
                        ComponentListItem(component: component)
                    }
                }
            }
            
            if !dish.instructions.isEmpty {
                Section(header: Text("instructions_title".localized)) {
                    Text(dish.instructions)
                }
            }
        }
        .navigationTitle(dish.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("edit".localized) {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                EditDishView(dish: dish)
            }
        }
        .confirmationDialog(
            "delete_dish_confirmation".localized,
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("delete".localized, role: .destructive) {
                deleteDish()
            }
            Button("cancel".localized, role: .cancel) { }
        } message: {
            Text("cannot_undo".localized)
        }
    }
    
    private func deleteDish() {
        modelContext.delete(dish)
        dismiss()
    }
}

private struct DishInfoSection: View {
    let dish: Dish
    
    var body: some View {
        GroupBox(label: Label("dish_details".localized, systemImage: "list.bullet")) {
            VStack(alignment: .leading, spacing: 15) {
                Text(dish.name)
                    .font(.title2)
                    .bold()
            }
            .padding()
        }
    }
}

private struct DishComponentsSection: View {
    let components: [DishComponent]
    
    var body: some View {
        GroupBox(label: Label("components_title".localized, systemImage: "square.stack.3d.up")) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(components) { component in
                    ComponentListItem(component: component)
                }
            }
            .padding()
        }
    }
}

private struct ComponentListItem: View {
    let component: DishComponent
    
    var body: some View {
        HStack {
            if let recipe = component.recipe {
                Text("\(recipe.name) (\("recipe_reference".localized))")
                    .foregroundStyle(.brown)
            } else {
                Text(component.name)
            }
            Spacer()
            Text("\(formatAmount(component.amount)) \(component.unit.rawValue)")
                .foregroundColor(.gray)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
}

private struct DishInstructionsSection: View {
    let instructions: String
    
    var body: some View {
        GroupBox(label: Label("instructions_title".localized, systemImage: "text.justify")) {
            Text(instructions)
                .padding()
        }
    }
}

private struct DeleteButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(role: .destructive, action: action) {
            HStack {
                Image(systemName: "trash")
                Text("delete_dish".localized)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .foregroundColor(.red)
            .cornerRadius(10)
        }
    }
} 
