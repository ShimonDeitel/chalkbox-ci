import Foundation
import Combine

@MainActor
final class ChalkboxStore: ObservableObject {
    @Published private(set) var items: [SupplyItem] = []

    private let fileURL: URL
    static let freeItemLimit = 5

    init(fileName: String = "chalkbox_items.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = dir.appendingPathComponent(fileName)
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
        }
        load()
        if ProcessInfo.processInfo.arguments.contains("-uiTestSeed") && items.isEmpty {
            seedForUITests()
        }
    }

    private func seedForUITests() {
        items = [
            SupplyItem(name: "Pencils", category: .writing, startingQuantity: 20, remaining: 20, lowStockThreshold: 5),
            SupplyItem(name: "Glue Sticks", category: .art, startingQuantity: 10, remaining: 2, lowStockThreshold: 3)
        ]
        save()
    }

    var lowStockItems: [SupplyItem] {
        items.filter { $0.isLowStock }.sorted { $0.remainingFraction < $1.remainingFraction }
    }

    var totalUsedThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return items.reduce(0) { total, item in
            total + item.usageLog.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
                .reduce(0) { $0 + $1.amount }
        }
    }

    func addItem(name: String, category: SupplyCategory, startingQuantity: Int, lowStockThreshold: Int) {
        let item = SupplyItem(
            name: name,
            category: category,
            startingQuantity: startingQuantity,
            lowStockThreshold: lowStockThreshold
        )
        items.append(item)
        save()
    }

    func logUsage(itemID: UUID, amount: Int) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[idx].logUsage(amount)
        save()
    }

    func restock(itemID: UUID, addAmount: Int) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[idx].restockRefill(addAmount)
        save()
    }

    func updateThreshold(itemID: UUID, threshold: Int) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[idx].lowStockThreshold = max(threshold, 0)
        save()
    }

    func deleteItem(itemID: UUID) {
        items.removeAll { $0.id == itemID }
        save()
    }

    func deleteAllData() {
        items = []
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([SupplyItem].self, from: data) {
            items = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
