import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    private let languageKey = "selectedLanguage"
    
    @Published private(set) var selectedLanguage: Language
    @Published var languageUpdateTrigger = false
    
    private init() {
        if let storedValue = UserDefaults.standard.string(forKey: languageKey),
           let language = Language(rawValue: storedValue) {
            self.selectedLanguage = language
        } else {
            self.selectedLanguage = .finnish
        }
    }
    
    func setLanguage(_ newLanguage: Language) {
        selectedLanguage = newLanguage
        UserDefaults.standard.set(newLanguage.rawValue, forKey: languageKey)
        UserDefaults.standard.synchronize()
        
        UserDefaults.standard.set([newLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        languageUpdateTrigger.toggle()
        objectWillChange.send()
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

struct LanguageManagerModifier: ViewModifier {
    @State private var languageUpdateTrigger = false
    
    func body(content: Content) -> some View {
        content
            .environment(\.locale, .init(identifier: SettingsManager.shared.selectedLanguage.rawValue))
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                languageUpdateTrigger.toggle()
            }
            .id(languageUpdateTrigger)
    }
}

extension View {
    func withLanguageManager() -> some View {
        modifier(LanguageManagerModifier())
    }
} 