import SwiftUI

// MARK: - App Theme

struct AppTheme {
    // Colors
    static let accent = Color.blue
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // Priority Colors
    static let priorityLow = Color.green
    static let priorityMedium = Color.orange
    static let priorityHigh = Color.red
    
    // Category Colors
    static let categoryColors: [Color] = [
        .blue, .green, .orange, .red,
        .purple, .pink, .cyan, .yellow
    ]
    
    // Spacing
    static let spacing: CGFloat = 16
    static let compactSpacing: CGFloat = 8
    static let largeSpacing: CGFloat = 24
    
    // Corner Radius
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let largeCornerRadius: CGFloat = 20
    
    // Font
    static let titleFont = Font.title.bold()
    static let headlineFont = Font.headline
    static let bodyFont = Font.body
    static let captionFont = Font.caption
}

// MARK: - Color Extensions

extension Color {
    static let theme = AppTheme.self
    
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let length = hexSanitized.count
        if length == 6 {
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        } else {
            self.init(red: 0, green: 0, blue: 0)
        }
    }
    
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(
            format: "#%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func listItemStyle() -> some View {
        self
            .padding(.vertical, AppTheme.compactSpacing)
            .padding(.horizontal, AppTheme.spacing)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(AppTheme.smallCornerRadius)
    }
}

// MARK: - Gradients

extension LinearGradient {
    static let blueGradient = LinearGradient(
        colors: [Color.blue, Color.blue.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let greenGradient = LinearGradient(
        colors: [Color.green, Color.green.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let orangeGradient = LinearGradient(
        colors: [Color.orange, Color.orange.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Dark Mode Support

extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
