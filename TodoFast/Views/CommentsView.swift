import SwiftUI
import SwiftData

struct CommentsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var newComment = ""
    
    let taskId: String
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    // Placeholder for comments
                    ContentUnavailableView(
                        "暂无评论",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("成为第一个评论者")
                    )
                    .padding(.top, 50)
                }
                .padding()
            }
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("添加评论...", text: $newComment, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5)
                
                Button {
                    // Add comment
                    newComment = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(newComment.isEmpty ? .secondary : .blue)
                }
                .disabled(newComment.isEmpty)
            }
            .padding()
        }
        .navigationTitle("评论")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CommentsView(taskId: "test-id")
    }
}
