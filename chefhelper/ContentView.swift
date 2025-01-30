import SwiftUI
import SwiftData
import Foundation

#if DEBUG
extension ContentView {
    func isUITesting() -> Bool {
        ProcessInfo.processInfo.arguments.contains("-ui-testing")
    }
}
#endif


// Main view with tabs
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                // Splash screen
                VStack {
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.brown)
                        .rotationEffect(.degrees(isLoading ? 360 : 0))
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isLoading)
                    
                    Text("ChefHelper")
                        .font(.system(.title, design: .rounded))
                        .foregroundColor(.brown)
                        .padding(.top)
                }
                .opacity(isLoading ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: isLoading)
            } else {
                // Main app content
                TabView {
                    RecipeListView()
                        .tabItem {
                            Label("recipes".localized, systemImage: "book")
                        }
                    
                    InventoryView()
                        .tabItem {
                            Label("inventory".localized, systemImage: "cube.box")
                        }

                    StaffView()
                        .tabItem {
                            Label("staff".localized, systemImage: "person.2")
                        }
                }
                .tint(.brown)
                .opacity(isLoading ? 0 : 1)
                .animation(.easeIn(duration: 0.5), value: isLoading)
            }
        }
        .id(settingsManager.languageUpdateTrigger)
        .onAppear {
            // Ajastin splash screenille
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Recipe.self,
            Ingredient.self,
            InventoryItem.self,
            Staff.self,
            WorkShift.self,
        ], inMemory: true)
}
