import SwiftUI
import SwiftData

@main
struct TodoFastApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [TaskModel.self, CategoryModel.self])
    }
}
