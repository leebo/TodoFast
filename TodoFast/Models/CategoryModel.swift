import Foundation
import SwiftData

@Model
final class CategoryModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var icon: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var tasks: [TaskModel] = []
    
    init(name: String, colorHex: String = "#007AFF", icon: String = "folder") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.icon = icon
        self.createdAt = Date()
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

import SwiftUI

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        if length == 6 {
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        } else {
            return nil
        }
    }
}
