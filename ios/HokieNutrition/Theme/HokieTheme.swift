import SwiftUI

enum HokieColors {
    static let primary = Color(hex: "6C012B")
    static let onPrimary = Color.white
    static let primaryContainer = Color(hex: "8B1F41")
    static let secondary = Color(hex: "994700")
    static let secondaryContainer = Color(hex: "FF8934")
    static let tertiary = Color(hex: "243449")
    static let background = Color(hex: "FFF8F7")
    static let onBackground = Color(hex: "24191B")
    static let onSurfaceVariant = Color(hex: "564145")
    static let surfaceContainerLowest = Color.white
    static let surfaceContainer = Color(hex: "FEE9EB")
    static let outline = Color(hex: "897175")
    static let outlineVariant = Color(hex: "DCBFC3")
    static let error = Color(hex: "BA1A1A")

    static let proteinChip = Color(hex: "FEE9EB")
    static let carbChip = Color(hex: "FFDBC8")
    static let fatChip = Color(hex: "E8EDF4")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

struct HokiePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(HokieColors.onPrimary)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(HokieColors.primary.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct HokieSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(HokieColors.primary)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(HokieColors.surfaceContainerLowest)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(HokieColors.outlineVariant, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct MacroChip: View {
    let label: String
    let value: String
    let tint: Color

    var body: some View {
        Text("\(value) \(label)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(HokieColors.onBackground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint)
            .clipShape(Capsule())
    }
}
