import Foundation

extension String {
    var localized: String {
        let language = SettingsManager.shared.selectedLanguage
        
        if let bundlePath = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
        }
        
        return self
    }
} 