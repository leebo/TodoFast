import Foundation
import SwiftUI

@Observable
class SyncService {
    static let shared = SyncService()
    
    private let apiClient = APIClient.shared
    private var syncTimer: Timer?
    
    var isSyncing = false
    var lastSyncTime: Date?
    var pendingChanges: [SyncChange] = []
    
    struct SyncChange: Identifiable {
        let id = UUID()
        let type: ChangeType
        let modelId: String
        let timestamp: Date
        
        enum ChangeType {
            case create
            case update
            case delete
        }
    }
    
    private init() {
        startPeriodicSync()
    }
    
    // MARK: - Sync Actions
    
    func syncNow() async {
        guard !isSyncing else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        // Process pending changes
        for change in pendingChanges {
            do {
                try await syncChange(change)
            } catch {
                print("Sync failed for \(change.modelId): \(error)")
            }
        }
        
        // Fetch remote changes
        do {
            try await fetchRemoteChanges()
            lastSyncTime = Date()
        } catch {
            print("Failed to fetch remote changes: \(error)")
        }
    }
    
    private func syncChange(_ change: SyncChange) async throws {
        // Implementation would sync individual change to server
    }
    
    private func fetchRemoteChanges() async throws {
        // Implementation would fetch changes since last sync
    }
    
    // MARK: - Periodic Sync
    
    private func startPeriodicSync() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { await self?.syncNow() }
        }
    }
    
    func stopPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    // MARK: - Queue Changes
    
    func queueCreate(modelId: String) {
        pendingChanges.append(SyncChange(type: .create, modelId: modelId, timestamp: Date()))
    }
    
    func queueUpdate(modelId: String) {
        // Update existing pending change or add new
        if let index = pendingChanges.firstIndex(where: { $0.modelId == modelId && $0.type != .delete }) {
            pendingChanges[index] = SyncChange(type: .update, modelId: modelId, timestamp: Date())
        } else {
            pendingChanges.append(SyncChange(type: .update, modelId: modelId, timestamp: Date()))
        }
    }
    
    func queueDelete(modelId: String) {
        // Remove any pending changes for this model
        pendingChanges.removeAll { $0.modelId == modelId }
        pendingChanges.append(SyncChange(type: .delete, modelId: modelId, timestamp: Date()))
    }
}
