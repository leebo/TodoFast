import SwiftUI
import SwiftData

struct CategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CategoryModel.createdAt) private var categories: [CategoryModel]
    
    @State private var showingAddCategory = false
    @State private var categoryToDelete: CategoryModel?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    CategoryRowView(category: category)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                categoryToDelete = category
                                showingDeleteAlert = true
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("分类")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
            .alert("删除分类", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    if let category = categoryToDelete {
                        modelContext.delete(category)
                    }
                }
            } message: {
                Text("确定要删除这个分类吗？相关的任务将变为无分类状态。")
            }
            .overlay {
                if categories.isEmpty {
                    ContentUnavailableView(
                        "暂无分类",
                        systemImage: "folder.badge.plus",
                        description: Text("点击右上角 + 添加分类")
                    )
                }
            }
        }
    }
}

struct CategoryRowView: View {
    let category: CategoryModel
    @Query(sort: \TaskModel.createdAt) private var allTasks: [TaskModel]
    
    var taskCount: Int {
        allTasks.filter { $0.category?.id == category.id && !$0.isCompleted }.count
    }
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundColor(category.color)
                .frame(width: 36, height: 36)
                .background(category.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.headline)
                
                Text("\(taskCount) 个未完成任务")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 4)
    }
}

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedColor = CategoryColor.blue
    @State private var selectedIcon = CategoryIcon.folder
    
    enum CategoryColor: String, CaseIterable, Identifiable {
        case blue = "#007AFF"
        case green = "#34C759"
        case orange = "#FF9500"
        case red = "#FF3B30"
        case purple = "#AF52DE"
        case pink = "#FF2D55"
        case teal = "#5AC8FA"
        case yellow = "#FFCC00"
        
        var id: String { rawValue }
        var name: String {
            switch self {
            case .blue: return "蓝色"
            case .green: return "绿色"
            case .orange: return "橙色"
            case .red: return "红色"
            case .purple: return "紫色"
            case .pink: return "粉色"
            case .teal: return "青色"
            case .yellow: return "黄色"
            }
        }
        var color: Color { Color(hex: rawValue) ?? .blue }
    }
    
    enum CategoryIcon: String, CaseIterable, Identifiable {
        case folder = "folder"
        case star = "star"
        case heart = "heart"
        case bookmark = "bookmark"
        case tag = "tag"
        case flag = "flag"
        case house = "house"
        case briefcase = "briefcase"
        case person = "person"
        case cart = "cart"
        
        var id: String { rawValue }
        var name: String { rawValue.capitalized }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("分类名称") {
                    TextField("输入名称", text: $name)
                }
                
                Section("颜色") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(CategoryColor.allCases) { color in
                            Circle()
                                .fill(color.color)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("图标") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(CategoryIcon.allCases) { icon in
                            Image(systemName: icon.rawValue)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Color.blue : Color.gray.opacity(0.1))
                                .foregroundColor(selectedIcon == icon ? .white : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("新建分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        let category = CategoryModel(
            name: name,
            colorHex: selectedColor.rawValue,
            icon: selectedIcon.rawValue
        )
        modelContext.insert(category)
        dismiss()
    }
}

#Preview {
    CategoryView()
        .modelContainer(for: CategoryModel.self, inMemory: true)
}
