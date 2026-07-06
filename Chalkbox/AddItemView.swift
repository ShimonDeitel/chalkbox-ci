import SwiftUI

struct AddItemView: View {
    @EnvironmentObject private var store: ChalkboxStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: SupplyCategory = .writing
    @State private var startingQuantity = 10
    @State private var lowStockThreshold = 3

    var body: some View {
        NavigationStack {
            Form {
                Section("Supply") {
                    TextField("Name (e.g. Pencils)", text: $name)
                        .accessibilityIdentifier("nameField")
                    Picker("Category", selection: $category) {
                        ForEach(SupplyCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.iconName).tag(cat)
                        }
                    }
                }

                Section("Stock") {
                    Stepper("Starting quantity: \(startingQuantity)", value: $startingQuantity, in: 1...999)
                        .accessibilityIdentifier("startingQuantityStepper")
                    Stepper("Low-stock alert at: \(lowStockThreshold)", value: $lowStockThreshold, in: 0...startingQuantity)
                        .accessibilityIdentifier("thresholdStepper")
                }
            }
            .dismissKeyboardOnTap()
            .navigationTitle("Add Supply")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.addItem(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? "Untitled Supply" : name,
                            category: category,
                            startingQuantity: startingQuantity,
                            lowStockThreshold: lowStockThreshold
                        )
                        dismiss()
                    }
                    .accessibilityIdentifier("saveItemButton")
                }
            }
        }
    }
}

#Preview {
    AddItemView()
        .environmentObject(ChalkboxStore())
}
