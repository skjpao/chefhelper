import Foundation

struct StaticIngredient: Identifiable {
    let id = UUID()
    let name: String
    let category: Category
}

struct StaticIngredients {
    static let all: [StaticIngredient] = [
        // Tuoretuotteet
        StaticIngredient(name: "carrot".localized, category: .fresh),
        StaticIngredient(name: "potato".localized, category: .fresh),
        StaticIngredient(name: "onion".localized, category: .fresh),
        StaticIngredient(name: "garlic".localized, category: .fresh),
        StaticIngredient(name: "tomato".localized, category: .fresh),
        StaticIngredient(name: "cucumber".localized, category: .fresh),
        StaticIngredient(name: "bell_pepper".localized, category: .fresh),
        StaticIngredient(name: "zucchini".localized, category: .fresh),
        StaticIngredient(name: "eggplant".localized, category: .fresh),
        StaticIngredient(name: "apple".localized, category: .fresh),
        StaticIngredient(name: "pear".localized, category: .fresh),
        StaticIngredient(name: "blueberry".localized, category: .fresh),
        StaticIngredient(name: "raspberry".localized, category: .fresh),
        StaticIngredient(name: "strawberry".localized, category: .fresh),
        StaticIngredient(name: "beef_tenderloin".localized, category: .fresh),
        StaticIngredient(name: "pork_loin".localized, category: .fresh),
        StaticIngredient(name: "chicken_breast".localized, category: .fresh),
        StaticIngredient(name: "lamb_chops".localized, category: .fresh),
        StaticIngredient(name: "duck_breast".localized, category: .fresh),
        StaticIngredient(name: "salmon".localized, category: .fresh),
        StaticIngredient(name: "whitefish".localized, category: .fresh),
        StaticIngredient(name: "perch".localized, category: .fresh),
        StaticIngredient(name: "pike_perch".localized, category: .fresh),
        StaticIngredient(name: "flounder".localized, category: .fresh),
        StaticIngredient(name: "cream".localized, category: .fresh),
        StaticIngredient(name: "milk".localized, category: .fresh),
        StaticIngredient(name: "butter".localized, category: .fresh),
        StaticIngredient(name: "mascarpone".localized, category: .fresh),
        StaticIngredient(name: "creme_fraiche".localized, category: .fresh),
        StaticIngredient(name: "basil".localized, category: .fresh),
        StaticIngredient(name: "thyme".localized, category: .fresh),
        StaticIngredient(name: "rosemary".localized, category: .fresh),
        StaticIngredient(name: "oregano".localized, category: .fresh),
        StaticIngredient(name: "parsley".localized, category: .fresh),
        
        // Kuiva-aineet
        StaticIngredient(name: "wheat_flour".localized, category: .dry),
        StaticIngredient(name: "rye_flour".localized, category: .dry),
        StaticIngredient(name: "buckwheat_flour".localized, category: .dry),
        StaticIngredient(name: "rice".localized, category: .dry),
        StaticIngredient(name: "pasta".localized, category: .dry),
        StaticIngredient(name: "black_pepper".localized, category: .dry),
        StaticIngredient(name: "cinnamon".localized, category: .dry),
        StaticIngredient(name: "cardamom".localized, category: .dry),
        StaticIngredient(name: "curry".localized, category: .dry),
        StaticIngredient(name: "paprika_powder".localized, category: .dry),
        
        // Muut
        StaticIngredient(name: "olive_oil".localized, category: .misc),
        StaticIngredient(name: "balsamic_vinegar".localized, category: .misc),
        StaticIngredient(name: "soy_sauce".localized, category: .misc),
        StaticIngredient(name: "honey".localized, category: .misc),
        StaticIngredient(name: "mustard".localized, category: .misc)
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