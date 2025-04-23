//
//  ChatManager.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 23/04/25.
//
import Foundation
import Combine

class ChatManager: ObservableObject, ChatProtocol {
    @Published var rooms: [String: PieSocketRoomClient] = [:]
    
    var roomsPublisher: Published<[String: PieSocketRoomClient]>.Publisher { $rooms }
    
    private var cancellables: [String: AnyCancellable] = [:]
    private let storage: ChatPersistenceProtocol
    
    weak var delegate: ChatManagerDelegate?
    
    init(storage: ChatPersistenceProtocol = ChatPersistenceService.shared) {
        self.storage = storage
    }

    func connectToRoom(_ roomName: String, channelId: String) {
        if rooms[roomName] == nil {
            let client = PieSocketRoomClient(delegate: self, roomName: roomName, channelId: channelId)
            
            let savedMessages = self.storage.load(forRoom: roomName)
            client.setInitialMessages(savedMessages)
            
            client.connect()
            rooms[roomName] = client
            
            cancellables[roomName] = client.$combinedMessages.sink { messages in
                self.rooms[roomName] = client
                self.storage.save(messages, forRoom: roomName)
            }
        }
    }
    
    func markMessageAsRead(messageId: UUID?, inRoom room: String) {
        guard let messages = rooms[room],
              let index = messages.combinedMessages.firstIndex(where: { $0.id == messageId }) else {
            return
        }

        // Copy, modify, and replace
        var updated = messages.combinedMessages[index]
        updated.isUnread = false
        messages.combinedMessages[index] = updated

        // Update the published value
        rooms[room] = messages
    }

    func send(message: ChatMessage) {
        rooms[message.botName]?.send(message)
    }

    func messages(for roomName: String) -> [ChatMessage] {
        rooms[roomName]?.combinedMessages ?? []
    }

    func disconnectRoom(_ roomName: String) {
        rooms[roomName]?.disconnect()
        rooms.removeValue(forKey: roomName)
    }

    func disconnectAll() {
        rooms.values.forEach { $0.disconnect() }
        rooms.removeAll()
    }
}

extension ChatManager: PieSocketRoomClientDelegate {
    func pieSocketClient(didReceiveError error: Error) {
        delegate?.chatManager(didReceiveError: error)
    }
}
