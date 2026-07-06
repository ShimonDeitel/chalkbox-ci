import Foundation

enum ChalkboxSheet: Identifiable, Equatable {
    case addItem
    case itemDetail(UUID)
    case paywall

    var id: String {
        switch self {
        case .addItem: return "addItem"
        case .itemDetail(let id): return "itemDetail-\(id.uuidString)"
        case .paywall: return "paywall"
        }
    }
}
