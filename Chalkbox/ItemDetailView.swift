import SwiftUI

struct ItemDetailView: View {
    let itemID: UUID
    @EnvironmentObject private var store: ChalkboxStore
    @Environment(\.dismiss) private var dismiss
    @State private var useAmount = 1
    @State private var restockAmount = 10
    @State private var showDeleteConfirm = false

    private var item: SupplyItem? {
        store.items.first(where: { $0.id == itemID })
    }

    var body: some View {
        NavigationStack {
            if let item {
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.name)
                                .font(CBTheme.titleFont)
                            ChalkStickView(fraction: item.remainingFraction, isLow: item.isLowStock)
                            Text("\(item.remaining) of \(item.startingQuantity) remaining")
                                .font(.subheadline)
                                .foregroundStyle(CBTheme.inkFaded)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                    }

                    Section("Log Usage") {
                        Stepper("Use \(useAmount)", value: $useAmount, in: 1...max(item.remaining, 1))
                            .accessibilityIdentifier("useAmountStepper")
                        Button("Log Usage") {
                            store.logUsage(itemID: item.id, amount: useAmount)
                            useAmount = 1
                        }
                        .buttonStyle(.plain)
                        .disabled(item.remaining <= 0)
                        .accessibilityIdentifier("logUsageButton")
                    }

                    Section("Restock") {
                        Stepper("Add \(restockAmount)", value: $restockAmount, in: 1...999)
                            .accessibilityIdentifier("restockAmountStepper")
                        Button("Restock") {
                            store.restock(itemID: item.id, addAmount: restockAmount)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("restockButton")
                    }

                    Section("Low-stock Alert") {
                        Stepper("Alert at \(item.lowStockThreshold)", value: Binding(
                            get: { item.lowStockThreshold },
                            set: { store.updateThreshold(itemID: item.id, threshold: $0) }
                        ), in: 0...max(item.startingQuantity, 1))
                        .accessibilityIdentifier("thresholdEditStepper")
                    }

                    Section {
                        Button("Delete Supply", role: .destructive) {
                            showDeleteConfirm = true
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("deleteItemButton")
                    }
                }
                .navigationTitle("Details")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
                .confirmationDialog(
                    "Delete this supply?",
                    isPresented: $showDeleteConfirm,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        store.deleteItem(itemID: item.id)
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            } else {
                Text("Supply not found")
                    .foregroundStyle(CBTheme.inkFaded)
            }
        }
    }
}

#Preview {
    let store = ChalkboxStore()
    return ItemDetailView(itemID: UUID())
        .environmentObject(store)
}
