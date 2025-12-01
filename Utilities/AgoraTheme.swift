import SwiftUI

enum AgoraTheme {
    static let background = Color(hex: "#F8F7F4") ?? Color(red: 0.97, green: 0.97, blue: 0.96)
    static let accent = Color(hex: "#8B5A3C") ?? Color(red: 0.55, green: 0.35, blue: 0.24)
    static let ink = Color(hex: "#1A2B4A") ?? Color(red: 0.10, green: 0.17, blue: 0.29)
    static let gold = Color(hex: "#D4AF37") ?? Color(red: 0.83, green: 0.69, blue: 0.22)
    static let sea = Color(hex: "#5FB3D5") ?? Color(red: 0.37, green: 0.70, blue: 0.84)
    static let marble = Color.white.opacity(0.92)
    
    static var headerTitle: Font { .system(size: 34, weight: .bold, design: .serif) }
    static var headerSubtitle: Font { .system(size: 18, weight: .regular, design: .serif) }
    static var bodySerif: Font { .system(size: 20, weight: .regular, design: .serif) }
    static var bodySans: Font { .system(size: 16, weight: .regular, design: .rounded) }
    static var actionSans: Font { .system(size: 17, weight: .semibold, design: .rounded) }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
