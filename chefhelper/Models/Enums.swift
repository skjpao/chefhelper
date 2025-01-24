import Foundation

enum Unit: String, Codable {
    case kg = "kg"
    case l = "l"
    case pieces = "kpl"
}

enum Category: String, Codable, CaseIterable {
    case all = "Kaikki"
    case fresh = "Tuoretuotteet"
    case dry = "Kuiva-aineet"
    case misc = "Muut"
    
    static var addCases: [Category] {
        [.fresh, .dry, .misc]
    }
}

enum Role: String, Codable, CaseIterable {
    case cook = "Kokki"
    case waiter = "Tarjoilija"
    case dishwasher = "Tiskari"
    case kitchenSupervisor = "Vuoropäällikkö (keittiö)"
    case serviceSupervisor = "Vuoropäällikkö (sali)"
    case headChef = "Keittiömestari"
    case restaurantManager = "Ravintolapäällikkö"
} 