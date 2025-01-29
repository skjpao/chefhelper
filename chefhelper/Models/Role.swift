enum Role: String, CaseIterable {
    case cook = "cook"
    case server = "server" 
    case dishwasher = "dishwasher"
    case kitchenSupervisor = "kitchen_supervisor"
    case serviceSupervisor = "service_supervisor"
    case headChef = "head_chef"
    case restaurantManager = "restaurant_manager"
    
    var localizedName: String {
        return rawValue.localized
    }
}
