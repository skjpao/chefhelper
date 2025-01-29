import SwiftUI
import SwiftData
import PhotosUI

struct AddDishView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name) private var recipes: [Recipe]
    
    @State private var name = ""
    @State private var components: [DishComponent] = []
    @State private var instructions = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingAddComponent = false
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data? = nil
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("dish_name".localized)) {
                    TextField("enter_dish_name".localized, text: $name)
                }
                
                Section(header: Text("components_title".localized)) {
                    ForEach(components) { component in
                        HStack {
                            if let recipe = component.getRecipe(context: modelContext) {
                                Text("\(recipe.name) (\("recipe_reference".localized))")
                                    .foregroundStyle(.brown)
                            } else {
                                Text(component.name)
                            }
                            Spacer()
                            Text(String(format: "%.0f %@", component.amount, component.unit.rawValue))
                        }
                    }
                    .onDelete(perform: deleteComponents)
                    
                    Button(action: addComponent) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("add_component".localized)
                        }
                        .foregroundColor(.brown)
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
                    .foregroundColor(.brown)
                }
            }
            
            // Bottom buttons with rustic styling
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
        .tint(.brown)
        .sheet(isPresented: $showingAddComponent) {
            AddComponentView(components: $components)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(imageData: $imageData)
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
    
    private func deleteComponents(at offsets: IndexSet) {
        components.remove(atOffsets: offsets)
    }
    
    private func addComponent() {
        showingAddComponent = true
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
        try? modelContext.save()
        dismiss()
    }
} 