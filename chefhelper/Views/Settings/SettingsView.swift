import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("language".localized)) {
                    Picker("select_language".localized, selection: Binding(
                        get: { settingsManager.selectedLanguage },
                        set: { settingsManager.setLanguage($0) }
                    )) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
} 