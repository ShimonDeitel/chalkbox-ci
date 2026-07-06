import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            ChalkboxHomeView()
                .tabItem {
                    Label("Supplies", systemImage: "shippingbox.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(CBTheme.busYellowDeep)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(CBTheme.chalk)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    RootTabView()
        .environmentObject(ChalkboxStore())
        .environmentObject(PurchaseManager())
}
