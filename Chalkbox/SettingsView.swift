import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: ChalkboxStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("chalkbox_default_threshold") private var defaultThreshold: Int = 3
    @State private var activeSheet: ChalkboxSheet?
    @State private var showResetConfirm = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Defaults") {
                    Stepper("Default low-stock alert: \(defaultThreshold)", value: $defaultThreshold, in: 0...20)
                        .accessibilityIdentifier("defaultThresholdStepper")
                }

                Section("Stats") {
                    HStack {
                        Text("Tracked Supplies")
                        Spacer()
                        Text("\(store.items.count)")
                            .foregroundStyle(CBTheme.inkFaded)
                    }
                    HStack {
                        Text("Used This Month")
                        Spacer()
                        Text("\(store.totalUsedThisMonth)")
                            .foregroundStyle(CBTheme.inkFaded)
                    }
                }

                Section("Chalkbox Pro") {
                    if purchases.isPro {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(CBTheme.busYellowDeep)
                    } else {
                        Button("Upgrade to Pro") {
                            activeSheet = .paywall
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("upgradeProButton")
                    }
                    Button("Restore Purchases") {
                        Task {
                            await purchases.restore()
                            restoreMessage = purchases.isPro ? "Purchases restored." : "No purchases found."
                        }
                    }
                    .buttonStyle(.plain)
                    if let restoreMessage {
                        Text(restoreMessage)
                            .font(.caption)
                            .foregroundStyle(CBTheme.inkFaded)
                    }
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/chalkbox-site/privacy.html")!)
                    Link("Contact Support", destination: URL(string: "mailto:s0533495227@gmail.com")!)
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(CBTheme.inkFaded)
                    }
                }

                Section {
                    Button("Reset All Data", role: .destructive) {
                        showResetConfirm = true
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("resetDataButton")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset all supplies and history?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .paywall:
                    PaywallView()
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ChalkboxStore())
        .environmentObject(PurchaseManager())
}
