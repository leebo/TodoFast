import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("showCompleted") private var showCompleted = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
                Section("外观") {
                    Toggle("深色模式", isOn: $isDarkMode)
                }
                
                Section("任务") {
                    Toggle("显示已完成任务", isOn: $showCompleted)
                }
                
                Section("通知") {
                    Toggle("启用提醒", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        NavigationLink("通知设置") {
                            Text("系统通知设置")
                        }
                    }
                }
                
                Section("账号") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("未登录")
                                .font(.headline)
                            Text("点击登录以同步数据")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Show login
                    }
                }
                
                Section("关于") {
                    LabeledContent("版本", value: "1.0.0")
                    LabeledContent("构建", value: "1")
                    
                    Link(destination: URL(string: "https://github.com/leebo/TodoFast")!) {
                        Label("GitHub", systemImage: "link")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

#Preview {
    SettingsView()
}
