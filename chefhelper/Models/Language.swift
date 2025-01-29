enum Language: String, CaseIterable {
    case finnish = "fi"
    case english = "en"
    case swedish = "sv"
    case spanish = "es"
    case italian = "it"
    case french = "fr"
    
    var displayName: String {
        switch self {
        case .finnish: return "Suomi"
        case .english: return "English"
        case .swedish: return "Svenska"
        case .spanish: return "Español"
        case .italian: return "Italiano"
        case .french: return "Français"
        }
    }
} 
