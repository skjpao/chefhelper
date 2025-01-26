import Foundation

struct StaticIngredient: Identifiable {
    let id = UUID()
    let name: String
    let category: Category
}

struct StaticIngredients {
    static let all: [StaticIngredient] = [
        // Tuoretuotteet
        StaticIngredient(name: "Porkkana", category: .fresh),
        StaticIngredient(name: "Peruna", category: .fresh),
        StaticIngredient(name: "Sipuli", category: .fresh),
        StaticIngredient(name: "Valkosipuli", category: .fresh),
        StaticIngredient(name: "Tomaatti", category: .fresh),
        StaticIngredient(name: "Kurkku", category: .fresh),
        StaticIngredient(name: "Paprika", category: .fresh),
        StaticIngredient(name: "Kesäkurpitsa", category: .fresh),
        StaticIngredient(name: "Munakoiso", category: .fresh),
        StaticIngredient(name: "Omena", category: .fresh),
        StaticIngredient(name: "Päärynä", category: .fresh),
        StaticIngredient(name: "Mustikka", category: .fresh),
        StaticIngredient(name: "Vadelma", category: .fresh),
        StaticIngredient(name: "Mansikka", category: .fresh),
        StaticIngredient(name: "Naudan sisäfilee", category: .fresh),
        StaticIngredient(name: "Porsaan ulkofilee", category: .fresh),
        StaticIngredient(name: "Kanan rintafilee", category: .fresh),
        StaticIngredient(name: "Lampaankareet", category: .fresh),
        StaticIngredient(name: "Ankanrinta", category: .fresh),
        StaticIngredient(name: "Lohi", category: .fresh),
        StaticIngredient(name: "Siika", category: .fresh),
        StaticIngredient(name: "Ahven", category: .fresh),
        StaticIngredient(name: "Kuha", category: .fresh),
        StaticIngredient(name: "Kampela", category: .fresh),
        StaticIngredient(name: "Kerma", category: .fresh),
        StaticIngredient(name: "Maito", category: .fresh),
        StaticIngredient(name: "Voi", category: .fresh),
        StaticIngredient(name: "Mascarpone", category: .fresh),
        StaticIngredient(name: "Creme fraiche", category: .fresh),
        StaticIngredient(name: "Basilika", category: .fresh),
        StaticIngredient(name: "Timjami", category: .fresh),
        StaticIngredient(name: "Rosmariini", category: .fresh),
        StaticIngredient(name: "Oregano", category: .fresh),
        StaticIngredient(name: "Persilja", category: .fresh),
        
        // Kuiva-aineet
        StaticIngredient(name: "Vehnäjauho", category: .dry),
        StaticIngredient(name: "Ruisjauho", category: .dry),
        StaticIngredient(name: "Tattarijauho", category: .dry),
        StaticIngredient(name: "Riisi", category: .dry),
        StaticIngredient(name: "Pasta", category: .dry),
        StaticIngredient(name: "Mustapippuri", category: .dry),
        StaticIngredient(name: "Kaneli", category: .dry),
        StaticIngredient(name: "Kardemumma", category: .dry),
        StaticIngredient(name: "Curry", category: .dry),
        StaticIngredient(name: "Paprikajauhe", category: .dry),
        
        // Muut
        StaticIngredient(name: "Oliiviöljy", category: .misc),
        StaticIngredient(name: "Balsamiviinietikka", category: .misc),
        StaticIngredient(name: "Soijakastike", category: .misc),
        StaticIngredient(name: "Hunaja", category: .misc),
        StaticIngredient(name: "Sinappi", category: .misc)
    ]
    
    static func ingredients(for category: Category? = nil) -> [StaticIngredient] {
        if let category = category {
            return all.filter { $0.category == category }
        }
        return all
    }
    
    static func search(_ query: String) -> [StaticIngredient] {
        guard !query.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
} 