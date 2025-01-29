import SwiftUI
import _PhotosUI_SwiftUI
import SwiftData

struct EditDishView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var dish: Dish
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    
    @State private var name: String
    @State private var components: [DishComponent]
    @State private var instructions: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingAddComponent = false
    @State private var showingCamera = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data? = nil
    @State private var showingRecipePicker = false
    @State private var searchText = ""
    
    init(dish: Dish) {
        self.dish = dish
        _name = State(initialValue: dish.name)
        _components = State(initialValue: dish.components)
        _instructions = State(initialValue: dish.instructions)
        _imageData = State(initialValue: dish.imageData)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("dish_details".localized)) {
                    TextField("dish_name".localized, text: $name)
                }
                
                Section(header: Text("components_title".localized)) {
                    ForEach(components) { component in
                        VStack(alignment: .leading) {
                            HStack {
                                if let recipe = component.getRecipe(context: modelContext) {
                                    Text("\(recipe.name) (\("recipe_reference".localized))")
                                        .foregroundStyle(.brown)
                                } else {
                                    Text(component.name)
                                }
                                Spacer()
                                Text("\(formatAmount(component.amount)) \(component.unit.rawValue)")
                                    .foregroundColor(.gray)
                            }
                            
                            // Varastotilanne
                            Text(component.inventoryStatus.message)
                                .font(.caption)
                                .foregroundColor(component.inventoryStatus.available ? .green : .red)
                        }
                    }
                    .onDelete(perform: deleteComponents)
                    
                    HStack {
                        Button("add_component".localized) {
                            showingAddComponent = true
                        }
                        
                        Spacer()
                        
                        Button("add_from_recipe".localized) {
                            showingRecipePicker = true
                        }
                    }
                }
                
                Section(header: Text("instructions_title".localized)) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("image".localized)) {
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        VStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                            
                            Button(role: .destructive) {
                                self.imageData = nil
                            } label: {
                                Text("remove_image".localized)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button("take_photo".localized) {
                        showingCamera = true
                    }
                }
            }
            .navigationTitle("edit_dish".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save".localized) { saveDish() }
                }
            }
            .sheet(isPresented: $showingAddComponent) {
                NavigationStack {
                    AddComponentView(components: $components, isEmbedded: true)
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(imageData: $imageData)
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
            .onChange(of: selectedImage) {
                Task {
                    if let data = try? await selectedImage?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return String(format: "%.1f", amount)
    }
    
    private func deleteComponents(at offsets: IndexSet) {
        components.remove(atOffsets: offsets)
    }
    
    private func saveDish() {
        guard !name.isEmpty else {
            alertMessage = "enter_dish_name".localized
            showingAlert = true
            return
        }
        
        dish.name = name
        dish.components = components
        dish.instructions = instructions
        dish.imageData = imageData
        
        dismiss()
    }
} 
