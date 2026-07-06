import SwiftUI

/// Chalkbox's signature quirky feature: each item's remaining stock renders as a
/// literal stick of chalk that visibly SHORTENS as you log usage — a stub of white
/// chalk against the chalkboard-green backdrop, with a soft dust-trail at the tip.
struct ChalkStickView: View {
    let fraction: Double
    let isLow: Bool

    private let maxWidth: CGFloat = 120
    private let height: CGFloat = 14

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height / 2)
                .fill(CBTheme.boardLight)
                .frame(width: maxWidth, height: height)

            RoundedRectangle(cornerRadius: height / 2)
                .fill(isLow ? CBTheme.busYellow : CBTheme.chalk)
                .frame(width: max(maxWidth * fraction, height), height: height)
                .overlay(
                    // chalk-dust flecks near the worn tip
                    HStack {
                        Spacer()
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(Color.white.opacity(0.5 - Double(i) * 0.15))
                                .frame(width: 3, height: 3)
                                .offset(y: CGFloat([-3, 2, -1][i]))
                        }
                        Spacer().frame(width: 4)
                    }
                    .frame(width: max(maxWidth * fraction, height))
                    , alignment: .trailing
                )
                .animation(.easeInOut(duration: 0.35), value: fraction)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ChalkStickView(fraction: 1.0, isLow: false)
        ChalkStickView(fraction: 0.5, isLow: false)
        ChalkStickView(fraction: 0.15, isLow: true)
    }
    .padding()
    .background(CBTheme.board)
}
