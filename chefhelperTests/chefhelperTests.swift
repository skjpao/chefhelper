import XCTest
import SwiftData
@testable import chefhelper

final class ChefHelperTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUpWithError() throws {
        let schema = Schema([
            InventoryItem.self,
            Recipe.self,
            Ingredient.self,
            Staff.self,
            WorkShift.self,
            Menu.self,
            Task.self,
            Supplier.self,
            Order.self,
            OrderItem.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        modelContainer = try ModelContainer(
            for: schema,
            configurations: modelConfiguration
        )
        modelContext = ModelContext(modelContainer)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }
    
    // MARK: - Inventory Tests
    
    func testCreateInventoryItem() throws {
        let item = InventoryItem(
            name: "Tomaatti",
            amount: 1.5,
            unit: .kg,
            category: .fresh,
            arrivalDate: Date()
        )
        
        modelContext.insert(item)
        
        let descriptor = FetchDescriptor<InventoryItem>(
            sortBy: [SortDescriptor(\.name)]
        )
        let items = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.name, "Tomaatti")
        XCTAssertEqual(items.first?.amount, 1.5)
        XCTAssertEqual(items.first?.unit, .kg)
    }
    
    // MARK: - Recipe Tests
    
    func testCreateRecipe() throws {
        let ingredient = Ingredient(
            name: "Tomaatti",
            amount: 1.5,
            unit: .kg
        )
        
        let recipe = Recipe(
            name: "Tomaattikeitto",
            ingredients: [ingredient],
            instructions: "Keitä tomaatit"
        )
        
        modelContext.insert(recipe)
        
        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.name, "Tomaattikeitto")
        XCTAssertEqual(recipes.first?.ingredients.count, 1)
    }
    
    // MARK: - Staff Tests
    
    func testCreateStaff() throws {
        let staff = Staff(
            name: "Matti Meikäläinen",
            role: "Kokki",
            contactInfo: "matti@email.com"
        )
        
        modelContext.insert(staff)
        
        let descriptor = FetchDescriptor<Staff>()
        let staffMembers = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(staffMembers.count, 1)
        XCTAssertEqual(staffMembers.first?.name, "Matti Meikäläinen")
        XCTAssertEqual(staffMembers.first?.role, "Kokki")
    }
    
    // MARK: - Relationship Tests
    
    func testRecipeIngredientRelationship() throws {
        let ingredient = Ingredient(
            name: "Tomaatti",
            amount: 1.5,
            unit: .kg
        )
        
        let recipe = Recipe(
            name: "Tomaattikeitto",
            ingredients: [ingredient],
            instructions: "Keitä tomaatit"
        )
        
        modelContext.insert(recipe)
        
        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(recipes.first?.ingredients.first?.name, "Tomaatti")
        XCTAssertEqual(recipes.first?.ingredients.first?.amount, 1.5)
    }
    
    func testStaffWorkShiftRelationship() throws {
        let staff = Staff(
            name: "Matti Meikäläinen",
            role: "Kokki",
            contactInfo: "matti@email.com"
        )
        
        let shift = WorkShift(
            date: Date(),
            startTime: Date(),
            endTime: Date().addingTimeInterval(8 * 3600),
            position: "Kokki"
        )
        
        staff.schedule.append(shift)
        modelContext.insert(staff)
        
        let descriptor = FetchDescriptor<Staff>()
        let staffMembers = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(staffMembers.first?.schedule.count, 1)
        XCTAssertEqual(staffMembers.first?.schedule.first?.position, "Kokki")
    }
}
