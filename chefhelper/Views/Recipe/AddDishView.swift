import SwiftUI
import SwiftData

struct AddDishView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var components: [DishComponent] = []
    @State private var instructions = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingAddComponent = false
    @State private var showingRecipePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(header: Text("dish_details".localized)) {
                    TextField("dish_name".localized, text: $name)
                }
                
                Section(header: Text("components_title".localized)) {
                    ForEach(components) { component in
                        ComponentRow(component: component, modelContext: modelContext)
                    }
                    .onDelete(perform: deleteComponents)
                    .onMove(perform: moveComponents)
                    
                    Button("add_component".localized) {
                        showingAddComponent = true
                    }
                }
                
                Section(header: Text("instructions_title".localized)) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 100)
                }
            }
            
            // Tallenna/Peruuta napit
            HStack {
                Button(action: { dismiss() }) {
                    Text("cancel".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown.opacity(0.1))
                        .foregroundColor(.brown)
                        .cornerRadius(8)
                }
                Button(action: saveDish) {
                    Text("save".localized)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brown)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("new_dish".localized)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddComponent) {
            NavigationStack {
                AddComponentView(components: $components, isEmbedded: true, dismissAfterAdd: true)
            }
        }
        .sheet(isPresented: $showingRecipePicker) {
            NavigationStack {
                RecipePickerView(components: $components)
            }
        }
        .alert("error".localized, isPresented: $showingAlert) {
            Button("ok".localized, role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
    
    private func deleteComponents(at offsets: IndexSet) {
        components.remove(atOffsets: offsets)
    }
    
    private func moveComponents(from source: IndexSet, to destination: Int) {
        components.move(fromOffsets: source, toOffset: destination)
    }
    
    private func saveDish() {
        guard !name.isEmpty else {
            alertMessage = "enter_dish_name".localized
            showingAlert = true
            return
        }
        
        let dish = Dish(
            name: name,
            components: components,
            instructions: instructions
        )
        
        modelContext.insert(dish)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
} 
