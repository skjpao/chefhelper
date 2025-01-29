enum Category: String, Codable, CaseIterable {
    case all = "All"
    case fresh = "Fresh"
    case dry = "Dry"
    case misc = "Misc"
    
    var localizedName: String {
        return self.rawValue.localized
    }
} 