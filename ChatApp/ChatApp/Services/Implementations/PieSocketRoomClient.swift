//
//  PieSocketRoomClient.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 23/04/25.
//


import Foundation


/*
 unsend Queue
 local save
 
 */

class PieSocketRoomClient: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var pingTimer: Timer?

    private let urlSession: URLSession
    private let channelId: String
    private let notifySelf: Bool
    private var roomName: String
    private var unsendMessage: String?
    
    private var networkMonitor: any NetworkMonitorProtocol
    
    private var unsentMessages: [ChatMessage] = []
    
    weak var delegate: PieSocketRoomClientDelegate?

    @Published var combinedMessages: [ChatMessage] = []

    init(delegate: PieSocketRoomClientDelegate? ,roomName: String, channelId: String, notifySelf: Bool = false, networkMonitor: any NetworkMonitorProtocol = NetworkMonitor()) {
        self.delegate = delegate
        self.roomName = roomName
        self.channelId = channelId
        self.notifySelf = notifySelf
        self.networkMonitor = networkMonitor
        self.urlSession = URLSession(configuration: .default)
        
        // Load previous chat history
        self.combinedMessages = ChatPersistenceService.shared.load(forRoom: roomName)
        
        // Load unsent messages (persisted)
        self.unsentMessages = self.combinedMessages.filter({ $0.isQueued })
        
        // Network Monitor to reconnect and resend the queued messages
        self.networkMonitor.onStatusChange = { isConnected in
            print("Connection changed: \(isConnected ? "Online" : "Offline")")
            
            if isConnected {
                self.reconnect()
                
            }
        }

        self.networkMonitor.startMonitoring()

    }

    func connect() {
        guard let url = URL(string: "wss://\(AppEnvironment.clusterID).piesocket.com/v3/\(channelId)?api_key=\(AppEnvironment.apiKey)\(notifySelf ? "&notify_self=true" : "")") else {
            print("Invalid URL")
            return
        }

        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()

        
        startPinging()
        listen()
        resendUnsentMessages()
        print("Connected to channel \(channelId)")
    }

    func disconnect() {
        stopPinging()
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        print("Disconnected from channel \(channelId)")
    }

    func send(_ message: ChatMessage) {
        self.unsendMessage = message.message
        let text = URLSessionWebSocketTask.Message.string(message.message)
        
        var temp = message
        
        if !networkMonitor.isConnected {
            temp.isQueued = true
            self.queueMessage(temp)
            self.delegate?.pieSocketClient(didReceiveError: APIError.custom(message: "The Internet connection appears to be offline"))
            return
        }
        
        guard let webSocketTask = webSocketTask else {
            temp.isQueued = true
            self.queueMessage(temp)
            self.delegate?.pieSocketClient(didReceiveError: APIError.custom(message: "The Internet connection appears to be offline"))
            
            return
        }
        
        webSocketTask.send(text) { [weak self] error in
            if let error = error {
                print("Send error: \(error)")
                self?.delegate?.pieSocketClient(didReceiveError: error)
                temp.isQueued = true
                self?.queueMessage(temp)
            } else {
                self?.addToMessages(message: message)
            }
        }
    }
    
    func setInitialMessages(_ messages: [ChatMessage]) {
        self.combinedMessages = messages
    }
    
    func resendUnsentMessages() {
        guard networkMonitor.isConnected, let webSocketTask = webSocketTask else { return }

        for message in unsentMessages {
            
            let text = URLSessionWebSocketTask.Message.string(message.message)
            webSocketTask.send(text) { error in
                if let error = error {
                    print("Resend failed: \(error)")
                } else {
                    self.markAsSent(message)
                }
            }
        }
    }
}

//MARK: Helper Methods
extension PieSocketRoomClient {
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("Receive error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self.unsendMessage = nil
                    self.addToMessages(message: ChatMessage(botName: self.roomName, message: text))
                    
                    
                default:
                    break
                }
                self.listen()
            }
        }
    }

    private func startPinging() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 25, repeats: true) { [weak self] _ in
            self?.webSocketTask?.sendPing { error in
                if let error = error {
                    print("Ping error: \(error)")
                }
            }
        }
    }

    private func stopPinging() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func reconnect() {
        disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connect()
        }
    }
    
    private func addToMessages(message: ChatMessage) {
        DispatchQueue.main.async {
            if let _ = self.unsentMessages.firstIndex(of: message) {
                self.markAsSent(message)
            } else {
                self.combinedMessages.append(message)
            }
        }
    }
    
    private func addMessage(message: ChatMessage) {
        self.combinedMessages.append(message)
    }

    private func addToQueue(message: ChatMessage) {
        self.unsentMessages.append(message)
    }
    
    private func queueMessage(_ message: ChatMessage) {
        DispatchQueue.main.async {
            if let _ = self.unsendMessage {
                self.addMessage(message: message)
                self.addToQueue(message: message)
                self.unsendMessage = nil
                
            }
        }
    }
    
    private func markAsSent(_ message: ChatMessage) {
        DispatchQueue.main.async {
            // Remove from unsent
            if let index = self.unsentMessages.firstIndex(of: message) {
                self.unsentMessages.remove(at: index)
                if let sentMessagesIndex = self.combinedMessages.firstIndex(of: message) {
                    var msg = message
                    msg.isQueued = false
                    self.combinedMessages[sentMessagesIndex] = msg
                }
            }
        }
    }
}
