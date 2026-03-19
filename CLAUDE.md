# Project: TodoFast iOS

## Overview
A modern iOS todo application with real-time sync and collaboration, built with SwiftUI and SwiftData.

## Tech Stack
- Language: Swift 5.9
- UI Framework: SwiftUI
- Persistence: SwiftData
- Architecture: MVVM
- Minimum iOS: 17.0

## Architecture
MVVM architecture with SwiftData for local persistence:

```
TodoFastApp.swift
    └── ContentView (TabView)
        ├── TaskListView (Task List Tab)
        ├── CategoryView (Categories Tab)
        └── SettingsView (Settings Tab)

Models/
    ├── TaskModel.swift (@Model)
    ├── CategoryModel.swift (@Model)
    └── UserModel.swift (@Model)

ViewModels/
    ├── TaskListViewModel.swift
    └── CategoryViewModel.swift

Services/
    ├── APIClient.swift
    ├── AuthService.swift
    ├── SyncService.swift
    └── WebSocketClient.swift
```

## Directory Structure
- `TodoFast/` - Main app target
- `TodoFast/Models/` - SwiftData models
- `TodoFast/Views/` - SwiftUI views
- `TodoFast/ViewModels/` - Business logic
- `TodoFast/Services/` - Networking and sync
- `TodoFast/Utils/` - Extensions and helpers

## Patterns & Conventions

### SwiftUI Patterns
- Use `@Observable` macro for view models (iOS 17+)
- Use `@Query` for fetching SwiftData objects
- Prefer `@Environment` for dependency injection

### SwiftData Patterns
- Models use `@Model` macro
- Relationships use `@Relationship` property wrapper
- Migrations handled automatically by SwiftData

### API Integration
- APIClient handles all network requests
- AuthService manages authentication state
- SyncService coordinates offline/online sync

## Environment
- Backend API: https://your-api.com/api/v1
- WebSocket: wss://your-api.com/ws

## Build & Test
- Build: `xcodebuild -scheme TodoFast -destination 'platform=iOS Simulator,name=iPhone 15'`
- Test: `xcodebuild test -scheme TodoFast -destination 'platform=iOS Simulator,name=iPhone 15'`

## Change Log
### 2026-03-19
- Initialized project memory
