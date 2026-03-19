import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            TaskListView()
                .tabItem {
                    Label("任务", systemImage: "checklist")
                }
            
            CategoryView()
                .tabItem {
                    Label("分类", systemImage: "folder")
                }
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TaskModel.self, CategoryModel.self], inMemory: true)
}
