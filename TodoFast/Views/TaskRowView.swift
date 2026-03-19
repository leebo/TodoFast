import SwiftUI

struct TaskRowView: View {
    let task: TaskModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion indicator
            Circle()
                .stroke(task.isCompleted ? Color.clear : task.priorityColor, lineWidth: 2)
                .fill(task.isCompleted ? task.priorityColor : Color.clear)
                .frame(width: 24, height: 24)
                .overlay {
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    // Priority
                    Label(task.priorityLabel, systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundColor(task.priorityColor)
                    
                    // Due date
                    if let dueDate = task.dueDate {
                        Label(dueDate.formatted(date: .abbreviated, time: .omitted), 
                              systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(dueDate < Date() && !task.isCompleted ? .red : .secondary)
                    }
                    
                    // Category
                    if let category = task.category {
                        Label(category.name, systemImage: category.icon)
                            .font(.caption)
                            .foregroundColor(category.color)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
