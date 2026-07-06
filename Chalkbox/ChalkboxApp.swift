import SwiftUI

@main
struct ChalkboxApp: App {
    @StateObject private var store = ChalkboxStore()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
        }
    }
}
