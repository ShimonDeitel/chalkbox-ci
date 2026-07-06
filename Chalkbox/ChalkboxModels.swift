import Foundation

enum SupplyCategory: String, Codable, CaseIterable, Identifiable {
    case writing = "Writing"
    case paper = "Paper"
    case art = "Art"
    case organization = "Organization"
    case other = "Other"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .writing: return "pencil"
        case .paper: return "doc.on.doc.fill"
        case .art: return "paintpalette.fill"
        case .organization: return "folder.fill"
        case .other: return "shippingbox.fill"
        }
    }
}

struct UsageEvent: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var amount: Int

    init(id: UUID = UUID(), date: Date = Date(), amount: Int) {
        self.id = id
        self.date = date
        self.amount = amount
    }
}

struct SupplyItem: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var category: SupplyCategory
    var startingQuantity: Int
    var remaining: Int
    var lowStockThreshold: Int
    var createdDate: Date
    var usageLog: [UsageEvent]

    init(
        id: UUID = UUID(),
        name: String,
        category: SupplyCategory,
        startingQuantity: Int,
        remaining: Int? = nil,
        lowStockThreshold: Int = 3,
        createdDate: Date = Date(),
        usageLog: [UsageEvent] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.startingQuantity = max(startingQuantity, 1)
        self.remaining = remaining ?? self.startingQuantity
        self.lowStockThreshold = max(lowStockThreshold, 0)
        self.createdDate = createdDate
        self.usageLog = usageLog
    }

    var usedCount: Int { startingQuantity - remaining }

    /// Fraction remaining, clamped 0...1 — drives the ChalkStickView's visual length.
    var remainingFraction: Double {
        guard startingQuantity > 0 else { return 0 }
        return min(max(Double(remaining) / Double(startingQuantity), 0), 1)
    }

    var isLowStock: Bool { remaining <= lowStockThreshold }
    var isOut: Bool { remaining <= 0 }

    mutating func logUsage(_ amount: Int) {
        guard amount > 0 else { return }
        let clamped = min(amount, remaining)
        guard clamped > 0 else { return }
        remaining -= clamped
        usageLog.append(UsageEvent(amount: clamped))
    }

    mutating func restock(to newTotal: Int) {
        let addedCapacity = max(newTotal - startingQuantity, 0)
        startingQuantity = max(newTotal, startingQuantity)
        remaining += addedCapacity == 0 ? (newTotal - remaining) : addedCapacity
        remaining = min(max(remaining, 0), startingQuantity)
    }

    mutating func restockRefill(_ amount: Int) {
        guard amount > 0 else { return }
        remaining = min(remaining + amount, startingQuantity)
    }
}
