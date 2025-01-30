import SwiftUI
import Foundation

enum Category: String, Codable, CaseIterable {
    case all = "all"
    case fresh = "fresh"
    case dry = "dry"
    case misc = "misc"
    
    var localizedName: String {
        return self.rawValue.localized
    }
} 