import XCTest

extension XCUIElement {
    func waitForExistence(timeout: TimeInterval = 5) -> Bool {
        return waitForExistence(timeout: timeout)
    }
    
    var isSelected: Bool {
        (value as? String) == "selected" || (value as? String)?.contains("selected") == true
    }
}

extension XCTestCase {
    func waitForElementToExist(_ element: XCUIElement, timeout: TimeInterval = 5) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout)
    }
}

extension XCUIApplication {
    func wait(for state: XCUIApplication.State, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate { (object, _) -> Bool in
            guard let app = object as? XCUIApplication else { return false }
            return app.state == state
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
} 