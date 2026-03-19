import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskModel.createdAt, order: .reverse) private var tasks: [TaskModel]
    @State private var viewModel = TaskListViewModel()
    @State private var showingAddTask = false
    @State private var selectedTask: TaskModel?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.filteredTasks(tasks)) { task in
                    TaskRowView(task: task)
                        .contentShape(Rectangle())
                        .onTapGesture { selectedTask = task }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteTask(task)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                            
                            Button {
                                viewModel.toggleTask(task)
                            } label: {
                                Label(task.isCompleted ? "未完成" : "完成", 
                                      systemImage: task.isCompleted ? "xmark.circle" : "checkmark.circle")
                            }
                            .tint(task.isCompleted ? .orange : .green)
                        }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "搜索任务")
            .navigationTitle("任务")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("排序", selection: $viewModel.sortOrder) {
                            ForEach(TaskListViewModel.SortOrder.allCases, id: \.self) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                        
                        Toggle("显示已完成", isOn: $viewModel.showCompleted)
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
            .overlay {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "暂无任务",
                        systemImage: "checklist",
                        description: Text("点击右上角 + 添加任务")
                    )
                }
            }
        }
    }
    
    private func deleteTask(_ task: TaskModel) {
        modelContext.delete(task)
    }
}

#Preview {
    TaskListView()
        .modelContainer(for: TaskModel.self, inMemory: true)
}
