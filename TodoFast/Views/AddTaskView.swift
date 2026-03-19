import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority = 1
    @State private var dueDate: Date?
    @State private var hasDueDate = false
    @State private var category: CategoryModel?
    
    @Query(sort: \CategoryModel.createdAt) private var categories: [CategoryModel]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("任务标题", text: $title)
                    TextField("描述（可选）", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("优先级") {
                    Picker("优先级", selection: $priority) {
                        Text("低").tag(0)
                        Text("中").tag(1)
                        Text("高").tag(2)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("截止日期") {
                    Toggle("设置截止日期", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker(
                            "截止日期",
                            selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }
                
                Section("分类") {
                    Picker("分类", selection: $category) {
                        Text("无").tag(nil as CategoryModel?)
                        ForEach(categories) { cat in
                            Label(cat.name, systemImage: cat.icon)
                                .tag(cat as CategoryModel?)
                        }
                    }
                }
            }
            .navigationTitle("新建任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        let task = TaskModel(
            title: title,
            taskDescription: description,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            category: category
        )
        
        modelContext.insert(task)
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: TaskModel.self, inMemory: true)
}
