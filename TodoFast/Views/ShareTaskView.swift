import SwiftUI

struct ShareTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var permission = "view"
    
    let taskId: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section("添加协作者") {
                    TextField("邮箱地址", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Picker("权限", selection: $permission) {
                        Text("只读").tag("view")
                        Text("编辑").tag("edit")
                        Text("管理").tag("admin")
                    }
                }
                
                Section {
                    Button("发送邀请") {
                        // Send invitation
                        dismiss()
                    }
                    .disabled(email.isEmpty || !email.contains("@"))
                }
            }
            .navigationTitle("分享任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

struct CollaboratorsView: View {
    let taskId: String
    
    var body: some View {
        List {
            Section("协作者") {
                // Placeholder for collaborator list
                Text("暂无协作者")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("协作者")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ShareTaskView(taskId: "test-id")
}
