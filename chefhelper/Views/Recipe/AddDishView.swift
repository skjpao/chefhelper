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
        Form {
            Section(header: Text("Annoksen tiedot")) {
                TextField("Nimi", text: $name)
                
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    VStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                        
                        Button(role: .destructive) {
                            $imageData.wrappedValue = nil
                        } label: {
                            Label("Poista kuva", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                HStack {
                    Button(action: { showingCamera = true }) {
                        Label("Ota kuva", systemImage: "camera")
                    }
                    
                    Spacer()
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Label("Valitse kuva", systemImage: "photo")
                    }
                }
            }
            
            Section(header: Text("Komponentit")) {
                ForEach(components) { component in
                    HStack {
                        if let recipe = component.getRecipe(context: modelContext) {
                            Text("\(recipe.name) (resepti)")
                                .foregroundStyle(.blue)
                        } else {
                            Text(component.name)
                        }
                        Spacer()
                        Text(String(format: "%.0f %@", component.amount, component.unit.rawValue))
                    }
                }
                .onDelete(perform: deleteComponents)
                
                Button("Lisää komponentti") {
                    showingAddComponent = true
                }
            }
            
            Section(header: Text("Valmistusohjeet")) {
                TextEditor(text: $instructions)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle("Uusi annos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Peruuta") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Lisää") { saveDish() }
            }
        }
        .sheet(isPresented: $showingAddComponent) {
            AddComponentView(components: $components)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(imageData: $imageData)
        }
        .alert("Virhe", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
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
    
    private func saveDish() {
        guard !name.isEmpty else {
            alertMessage = "Syötä annoksen nimi"
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