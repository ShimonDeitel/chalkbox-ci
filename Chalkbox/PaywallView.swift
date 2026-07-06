import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(CBTheme.busYellowDeep)
                    .padding(.top, 32)

                Text("Chalkbox Pro")
                    .font(CBTheme.titleFont)

                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(text: "Unlimited tracked supplies")
                    FeatureRow(text: "Unlimited usage history")
                    FeatureRow(text: "Support future updates")
                }
                .padding(.horizontal, 32)

                Spacer()

                Button {
                    isPurchasing = true
                    Task {
                        await purchases.purchase()
                        isPurchasing = false
                        if purchases.isPro { dismiss() }
                    }
                } label: {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        Text(purchases.product.map { "Unlock for \($0.displayPrice)" } ?? "Unlock Pro")
                            .font(.headline)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(CBTheme.busYellow)
                .foregroundStyle(CBTheme.ink)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 24)
                .accessibilityIdentifier("purchaseProButton")

                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private struct FeatureRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(CBTheme.success)
            Text(text)
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseManager())
}
