//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//
import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var chatMessages: [String: PieSocketRoomClient] = [:]
    @Published var apiError: APIError?

    private let activeRoomService: ActiveRoomProtocol
    private let persistenceService: ChatPersistenceProtocol
    private let networkMonitor: any NetworkMonitorProtocol
    private var chatManager: ChatProtocol

    private var cancellables = Set<AnyCancellable>()
    

    init(activeRoomService: ActiveRoomProtocol = ActiveRoomsService(),
         persistenceService: ChatPersistenceProtocol = ChatPersistenceService.shared,
         networkMonitor: any NetworkMonitorProtocol = NetworkMonitor(), chatManager: ChatProtocol = ChatManager()) {
        self.activeRoomService = activeRoomService
        self.persistenceService = persistenceService
        self.networkMonitor = networkMonitor
        self.chatManager = chatManager
        self.chatManager.delegate = self
        
        Task {
            await self.observeRoomsAndMessages()
        }
        observeMessages()
    }

    func sendMessage(roomid: Int, bot: String, text: String) {
        var msg = ChatMessage(id: UUID(), botName: bot, message: text, timestamp: Date(), isUnread: false)

        if networkMonitor.isConnected {
            msg.isQueued = false
            chatManager.send(message: msg)
        } else {
            msg.isQueued = true
            chatManager.send(message: msg)
        }
        
    }
    
    func markMessageAsRead(messageId: UUID?, inRoom room: String) {
        self.chatManager.markMessageAsRead(messageId: messageId, inRoom: room)
    }

    private func observeMessages() {
        chatManager.roomsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMessages in
                self?.chatMessages = newMessages
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func observeRoomsAndMessages() {
        
        Task {  [weak self] in
            guard let self else { return }
            do {
                let rooms = try await activeRoomService.loadRooms()
                switch rooms {
                case .success(let rooms):
                    if rooms.count > 0 {
                        for (index, room) in rooms.enumerated() {
                            switch index {
                            case 0 :
                                chatManager.connectToRoom(RoomsEnum.SupportBot.rawValue, channelId: room.channel_id.description)
                            case 1:
                                chatManager.connectToRoom(RoomsEnum.SalesBot.rawValue, channelId: room.channel_id.description)
                            case 2:
                                chatManager.connectToRoom(RoomsEnum.FAQBot.rawValue, channelId: room.channel_id.description)
                            default:
                                chatManager.connectToRoom("New", channelId: room.channel_id.description)
                            }
                        }
                    } else {
                        self.apiError = .custom(message: "No Rooms Found")
                        
                        
                    }
                case .failure(let failure):
                        self.apiError = failure
                }
            } catch let error as APIError {
                self.apiError = error
                
            } catch let error {
                self.apiError = .custom(message: error.localizedDescription)
            }
            
        }
        
    }
}

extension ChatViewModel: ChatManagerDelegate {
    func chatManager(didReceiveError error: Error) {
        DispatchQueue.main.async {
            self.apiError = .custom(message: error.localizedDescription)
        }
    }
}
