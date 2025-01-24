//
//  chefhelperUITests.swift
//  chefhelperUITests
//
//  Created by admin on 20.1.2025.
//

import XCTest

final class ChefHelperUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testBasicTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
    }
}
