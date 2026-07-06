import SwiftUI

/// Chalkbox's identity: a chalkboard-green / chalk-white / school-bus-yellow
/// classroom palette — distinct from every sibling app's colors.
enum CBTheme {
    static let backdrop = Color(red: 0.937, green: 0.949, blue: 0.937)   // pale chalk-dust
    static let board = Color(red: 0.129, green: 0.267, blue: 0.208)      // deep chalkboard green
    static let boardLight = Color(red: 0.165, green: 0.322, blue: 0.251)
    static let chalk = Color(red: 0.980, green: 0.976, blue: 0.949)      // chalk-white
    static let ink = Color(red: 0.098, green: 0.145, blue: 0.114)
    static let inkFaded = Color(red: 0.098, green: 0.145, blue: 0.114).opacity(0.55)
    static let rule = Color.black.opacity(0.08)

    static let busYellow = Color(red: 0.988, green: 0.757, blue: 0.106)
    static let busYellowDeep = Color(red: 0.867, green: 0.616, blue: 0.043)
    static let danger = Color(red: 0.808, green: 0.294, blue: 0.263)
    static let success = Color(red: 0.278, green: 0.522, blue: 0.365)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}
