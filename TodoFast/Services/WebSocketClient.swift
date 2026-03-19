import Foundation

class WebSocketClient: NSObject, ObservableObject {
    static let shared = WebSocketClient()
    
    @Published var isConnected = false
    @Published var lastMessage: String?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let baseURL = "ws://localhost:8080/ws"
    
    private override init() {
        super.init()
    }
    
    // MARK: - Connection
    
    func connect(token: String) {
        guard let url = URL(string: baseURL) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = session.webSocketTask(with: request)
        
        webSocketTask?.resume()
        isConnected = true
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
    
    // MARK: - Send/Receive
    
    func send<T: Encodable>(_ message: T) {
        guard let data = try? JSONEncoder().encode(message),
              let string = String(data: data, encoding: .utf8) else { return }
        
        webSocketTask?.send(.string(string)) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.lastMessage = text
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.lastMessage = text
                    }
                @unknown default:
                    break
                }
                
                // Continue receiving
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.isConnected = false
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        print("WebSocket connected")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        print("WebSocket disconnected")
    }
}

// MARK: - Message Types

struct WSMessage<T: Codable>: Codable {
    let type: String
    let payload: T
}

enum MessageType: String, Codable {
    case task_created
    case task_updated
    case task_deleted
    case task_completed
}
