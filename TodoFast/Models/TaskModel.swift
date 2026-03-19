import Foundation
import SwiftData

@Model
final class TaskModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var taskDescription: String
    var isCompleted: Bool
    var priority: Int // 0: low, 1: medium, 2: high
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \CategoryModel.tasks)
    var category: CategoryModel?
    
    init(
        title: String,
        taskDescription: String = "",
        priority: Int = 1,
        dueDate: Date? = nil,
        category: CategoryModel? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.taskDescription = taskDescription
        self.isCompleted = false
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = Date()
        self.updatedAt = Date()
        self.category = category
    }
    
    var priorityColor: Color {
        switch priority {
        case 0: return .green
        case 1: return .orange
        case 2: return .red
        default: return .gray
        }
    }
    
    var priorityLabel: String {
        switch priority {
        case 0: return "低"
        case 1: return "中"
        case 2: return "高"
        default: return ""
        }
    }
}

import SwiftUI
