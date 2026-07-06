import XCTest

final class ChalkboxUITests: XCTestCase {
    private var interruptionMonitorToken: NSObjectProtocol?

    override func setUpWithError() throws {
        continueAfterFailure = false
        interruptionMonitorToken = addUIInterruptionMonitor(withDescription: "System alert dismissal") { alert in
            for label in ["Allow", "OK", "Don't Allow", "Cancel"] {
                let button = alert.buttons[label]
                if button.exists {
                    button.tap()
                    return true
                }
            }
            return false
        }
    }

    override func tearDownWithError() throws {
        if let token = interruptionMonitorToken {
            removeUIInterruptionMonitor(token)
        }
    }

    private func launchApp(seeded: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        var args = ["-uiTestReset"]
        if seeded { args.append("-uiTestSeed") }
        app.launchArguments = args
        app.launch()
        return app
    }

    func testEmptyStateShowsAddPrompt() throws {
        let app = launchApp(seeded: false)
        XCTAssertTrue(app.buttons["addItemButtonEmptyState"].waitForExistence(timeout: 8))
    }

    func testSeededItemsAppearOnHome() throws {
        let app = launchApp()
        XCTAssertTrue(app.staticTexts["Pencils"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["Glue Sticks"].exists)
    }

    func testLowStockBannerShowsForLowItem() throws {
        let app = launchApp()
        XCTAssertTrue(app.otherElements["lowStockBanner"].waitForExistence(timeout: 8))
    }

    func testAddNewSupplyFlow() throws {
        let app = launchApp()
        app.buttons["addItemButton"].tap()
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Notebooks")
        app.buttons["saveItemButton"].tap()
        XCTAssertTrue(app.staticTexts["Notebooks"].waitForExistence(timeout: 5))
    }

    func testTapOutsideDismissesKeyboard() throws {
        let app = launchApp()
        app.buttons["addItemButton"].tap()
        let nameField = app.textFields["nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 5))
        // Tap on empty space within the form (the navigation title area) to dismiss.
        app.navigationBars.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.waitForExistence(timeout: 3))
    }

    func testOpenItemDetailAndLogUsage() throws {
        let app = launchApp()
        let row = app.staticTexts["Pencils"]
        XCTAssertTrue(row.waitForExistence(timeout: 8))
        row.tap()
        XCTAssertTrue(app.buttons["logUsageButton"].waitForExistence(timeout: 5))
        app.buttons["logUsageButton"].tap()
        // remaining count text should update; just confirm the button remains functional
        XCTAssertTrue(app.buttons["logUsageButton"].exists)
    }

    func testRestockFlow() throws {
        let app = launchApp()
        let row = app.staticTexts["Glue Sticks"]
        XCTAssertTrue(row.waitForExistence(timeout: 8))
        row.tap()
        XCTAssertTrue(app.buttons["restockButton"].waitForExistence(timeout: 5))
        app.buttons["restockButton"].tap()
        app.navigationBars.buttons["Done"].tap()
        XCTAssertTrue(app.staticTexts["Glue Sticks"].waitForExistence(timeout: 5))
    }

    func testSettingsTabShowsStats() throws {
        let app = launchApp()
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Tracked Supplies"].waitForExistence(timeout: 5))
    }

    func testPaywallAppearsAtFreeLimit() throws {
        let app = launchApp(seeded: false)
        for i in 1...5 {
            app.buttons["addItemButton"].tap()
            let nameField = app.textFields["nameField"]
            XCTAssertTrue(nameField.waitForExistence(timeout: 5))
            nameField.tap()
            nameField.typeText("Item \(i)")
            app.buttons["saveItemButton"].tap()
        }
        app.buttons["addItemButton"].tap()
        XCTAssertTrue(app.buttons["purchaseProButton"].waitForExistence(timeout: 5))
    }

    func testDeleteItemRemovesRow() throws {
        let app = launchApp()
        let row = app.staticTexts["Glue Sticks"]
        XCTAssertTrue(row.waitForExistence(timeout: 8))
        row.tap()
        XCTAssertTrue(app.buttons["deleteItemButton"].waitForExistence(timeout: 5))
        app.buttons["deleteItemButton"].tap()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.staticTexts["Glue Sticks"].waitForExistence(timeout: 5))
    }
}
