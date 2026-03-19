import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var task: TaskModel
    @State private var isEditing = false
    
    @Query(sort: \CategoryModel.createdAt) private var categories: [CategoryModel]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("状态") {
                    Toggle("已完成", isOn: $task.isCompleted)
                        .tint(.green)
                }
                
                Section("基本信息") {
                    if isEditing {
                        TextField("标题", text: $task.title)
                        TextField("描述", text: $task.taskDescription, axis: .vertical)
                            .lineLimit(3...6)
                    } else {
                        LabeledContent("标题", value: task.title)
                        LabeledContent("描述") {
                            Text(task.taskDescription.isEmpty ? "无" : task.taskDescription)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("详情") {
                    if isEditing {
                        Picker("优先级", selection: $task.priority) {
                            Text("低").tag(0)
                            Text("中").tag(1)
                            Text("高").tag(2)
                        }
                        
                        Picker("分类", selection: $task.category) {
                            Text("无").tag(nil as CategoryModel?)
                            ForEach(categories) { cat in
                                Label(cat.name, systemImage: cat.icon)
                                    .tag(cat as CategoryModel?)
                            }
                        }
                    } else {
                        LabeledContent("优先级", value: task.priorityLabel)
                        LabeledContent("分类") {
                            if let category = task.category {
                                Label(category.name, systemImage: category.icon)
                                    .foregroundColor(category.color)
                            } else {
                                Text("无").foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("时间") {
                    LabeledContent("创建时间", value: task.createdAt.formatted())
                    LabeledContent("更新时间", value: task.updatedAt.formatted())
                }
            }
            .navigationTitle("任务详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "完成" : "编辑") {
                        if isEditing {
                            task.updatedAt = Date()
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
    }
}
