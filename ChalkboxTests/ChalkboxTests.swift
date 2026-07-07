import XCTest
@testable import Chalkbox

@MainActor
final class ChalkboxTests: XCTestCase {
    var store: ChalkboxStore!
    let testFile = "chalkbox_test_items.json"

    override func setUp() {
        super.setUp()
        store = ChalkboxStore(fileName: testFile)
        store.deleteAllData()
    }

    override func tearDown() {
        store.deleteAllData()
        super.tearDown()
    }

    func testAddItemDefaultsRemainingToStarting() {
        store.addItem(name: "Pencils", category: .writing, startingQuantity: 20, lowStockThreshold: 5)
        XCTAssertEqual(store.items.count, 1)
        XCTAssertEqual(store.items[0].remaining, 20)
        XCTAssertEqual(store.items[0].usedCount, 0)
    }

    func testLogUsageDecrementsRemaining() {
        store.addItem(name: "Glue Sticks", category: .art, startingQuantity: 10, lowStockThreshold: 2)
        let id = store.items[0].id
        store.logUsage(itemID: id, amount: 3)
        XCTAssertEqual(store.items[0].remaining, 7)
        XCTAssertEqual(store.items[0].usedCount, 3)
        XCTAssertEqual(store.items[0].usageLog.count, 1)
    }

    func testLogUsageCannotGoNegative() {
        store.addItem(name: "Folders", category: .organization, startingQuantity: 5, lowStockThreshold: 1)
        let id = store.items[0].id
        store.logUsage(itemID: id, amount: 10)
        XCTAssertEqual(store.items[0].remaining, 0)
        XCTAssertTrue(store.items[0].isOut)
    }

    func testRestockIncreasesRemainingUpToStarting() {
        store.addItem(name: "Paper", category: .paper, startingQuantity: 100, lowStockThreshold: 10)
        let id = store.items[0].id
        store.logUsage(itemID: id, amount: 50)
        store.restock(itemID: id, addAmount: 20)
        XCTAssertEqual(store.items[0].remaining, 70)
    }

    func testRestockCannotExceedStartingQuantity() {
        store.addItem(name: "Erasers", category: .writing, startingQuantity: 10, lowStockThreshold: 2)
        let id = store.items[0].id
        store.logUsage(itemID: id, amount: 2)
        store.restock(itemID: id, addAmount: 100)
        XCTAssertEqual(store.items[0].remaining, 10)
    }

    func testIsLowStockThreshold() {
        store.addItem(name: "Markers", category: .art, startingQuantity: 10, lowStockThreshold: 3)
        let id = store.items[0].id
        XCTAssertFalse(store.items[0].isLowStock)
        store.logUsage(itemID: id, amount: 8)
        XCTAssertTrue(store.items[0].isLowStock)
    }

    func testLowStockItemsListPopulates() {
        store.addItem(name: "Crayons", category: .art, startingQuantity: 10, lowStockThreshold: 5)
        store.addItem(name: "Rulers", category: .other, startingQuantity: 10, lowStockThreshold: 2)
        let cray = store.items[0].id
        store.logUsage(itemID: cray, amount: 8)
        XCTAssertEqual(store.lowStockItems.count, 1)
        XCTAssertEqual(store.lowStockItems.first?.name, "Crayons")
    }

    func testDeleteItemRemovesFromList() {
        store.addItem(name: "Tape", category: .other, startingQuantity: 5, lowStockThreshold: 1)
        let id = store.items[0].id
        store.deleteItem(itemID: id)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testUpdateThresholdChangesLowStockFlag() {
        store.addItem(name: "Binders", category: .organization, startingQuantity: 10, lowStockThreshold: 1)
        let id = store.items[0].id
        store.logUsage(itemID: id, amount: 5)
        XCTAssertFalse(store.items[0].isLowStock)
        store.updateThreshold(itemID: id, threshold: 6)
        XCTAssertTrue(store.items[0].isLowStock)
    }

    func testRemainingFractionComputesCorrectly() {
        store.addItem(name: "Scissors", category: .other, startingQuantity: 4, lowStockThreshold: 1)
        let id = store.items[0].id
        store.logUsage(itemID: id, amount: 1)
        XCTAssertEqual(store.items[0].remainingFraction, 0.75, accuracy: 0.001)
    }

    func testDeleteAllDataClearsEverything() {
        store.addItem(name: "Notebooks", category: .paper, startingQuantity: 10, lowStockThreshold: 2)
        store.addItem(name: "Chalk", category: .other, startingQuantity: 5, lowStockThreshold: 1)
        store.deleteAllData()
        XCTAssertTrue(store.items.isEmpty)
    }

    func testTotalUsedThisMonthAggregates() {
        store.addItem(name: "Post-its", category: .paper, startingQuantity: 50, lowStockThreshold: 5)
        let id = store.items[0].id
        store.logUsage(itemID: id, amount: 5)
        store.logUsage(itemID: id, amount: 3)
        XCTAssertEqual(store.totalUsedThisMonth, 8)
    }

    func testPersistenceRoundTrip() {
        store.addItem(name: "Highlighters", category: .writing, startingQuantity: 12, lowStockThreshold: 3)
        let reloaded = ChalkboxStore(fileName: testFile)
        XCTAssertEqual(reloaded.items.count, 1)
        XCTAssertEqual(reloaded.items[0].name, "Highlighters")
    }
}
