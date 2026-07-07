import SwiftUI

struct ChalkboxHomeView: View {
    @EnvironmentObject private var store: ChalkboxStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var activeSheet: ChalkboxSheet?

    var body: some View {
        NavigationStack {
            ZStack {
                CBTheme.backdrop.ignoresSafeArea()

                if store.items.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if !store.lowStockItems.isEmpty {
                                lowStockBanner
                            }
                            LazyVStack(spacing: 12) {
                                ForEach(store.items) { item in
                                    SupplyRow(item: item)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            activeSheet = .itemDetail(item.id)
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Chalkbox")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if !purchases.isPro && store.items.count >= ChalkboxStore.freeItemLimit {
                            activeSheet = .paywall
                        } else {
                            activeSheet = .addItem
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addItemButton")
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .addItem:
                    AddItemView()
                case .itemDetail(let id):
                    if let item = store.items.first(where: { $0.id == id }) {
                        ItemDetailView(itemID: item.id)
                    }
                case .paywall:
                    PaywallView()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 56))
                .foregroundStyle(CBTheme.board.opacity(0.35))
            Text("No supplies tracked yet")
                .font(CBTheme.headlineFont)
                .foregroundStyle(CBTheme.ink)
            Text("Add your first supply to start tracking used vs. remaining.")
                .font(.subheadline)
                .foregroundStyle(CBTheme.inkFaded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Add Supply") {
                activeSheet = .addItem
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(CBTheme.busYellow)
            .foregroundStyle(CBTheme.ink)
            .clipShape(Capsule())
            .accessibilityIdentifier("addItemButtonEmptyState")
        }
    }

    private var lowStockBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(CBTheme.busYellowDeep)
            Text("\(store.lowStockItems.count) item\(store.lowStockItems.count == 1 ? "" : "s") running low")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CBTheme.ink)
            Spacer()
        }
        .padding(12)
        .background(CBTheme.busYellow.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("lowStockBanner")
    }
}

private struct SupplyRow: View {
    let item: SupplyItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.category.iconName)
                .font(.system(size: 18))
                .foregroundStyle(CBTheme.chalk)
                .frame(width: 40, height: 40)
                .background(CBTheme.board)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(CBTheme.ink)
                ChalkStickView(fraction: item.remainingFraction, isLow: item.isLowStock)
                Text("\(item.remaining) of \(item.startingQuantity) remaining")
                    .font(.caption)
                    .foregroundStyle(CBTheme.inkFaded)
            }

            Spacer()

            if item.isLowStock {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(CBTheme.busYellowDeep)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityIdentifier("supplyRow_\(item.name)")
    }
}

#Preview {
    let store = ChalkboxStore()
    return ChalkboxHomeView()
        .environmentObject(store)
        .environmentObject(PurchaseManager())
}
