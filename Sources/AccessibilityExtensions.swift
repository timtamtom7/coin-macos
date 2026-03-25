import SwiftUI
extension View {
    func accessibilitySecurityLabel(issue: String) -> some View {
        self.accessibilityLabel("Security issue: \(issue)")
    }
}
