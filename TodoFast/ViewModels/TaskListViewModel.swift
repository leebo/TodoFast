import SwiftUI
import SwiftData

@Observable
class TaskListViewModel {
    var searchText: String = ""
    var showCompleted: Bool = false
    var sortOrder: SortOrder = .createdAt
    
    enum SortOrder: String, CaseIterable {
        case createdAt = "创建时间"
        case dueDate = "截止日期"
        case priority = "优先级"
        case title = "标题"
    }
    
    func filteredTasks(_ tasks: [TaskModel]) -> [TaskModel] {
        var result = tasks
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.taskDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Completion filter
        if !showCompleted {
            result = result.filter { !$0.isCompleted }
        }
        
        // Sort
        switch sortOrder {
        case .createdAt:
            result.sort { $0.createdAt > $1.createdAt }
        case .dueDate:
            result.sort { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        case .priority:
            result.sort { $0.priority > $1.priority }
        case .title:
            result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        }
        
        return result
    }
    
    func toggleTask(_ task: TaskModel) {
        task.isCompleted.toggle()
        task.updatedAt = Date()
    }
}
