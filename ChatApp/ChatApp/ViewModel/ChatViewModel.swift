//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//
import Foundation
import Combine

enum Loader {
    case center, refresh
}

class ChatViewModel: ObservableObject {
    @Published var chatMessages: [String: PieSocketRoomClient] = [:]
    @Published var apiError: APIError?
    @Published var isLoading = false

    private let activeRoomService: ActiveRoomProtocol
    private let persistenceService: ChatPersistenceProtocol
    private var chatManager: ChatProtocol

    private var cancellables = Set<AnyCancellable>()
    

    init(activeRoomService: ActiveRoomProtocol = ActiveRoomsService(),
         persistenceService: ChatPersistenceProtocol = ChatPersistenceService.shared, chatManager: ChatProtocol = ChatManager()) {
        self.activeRoomService = activeRoomService
        self.persistenceService = persistenceService
        self.chatManager = chatManager
        self.chatManager.delegate = self
        
        Task {
            await self.observeRoomsAndMessages(loader: .center)
        }
        observeMessages()
    }

    func sendMessage(roomid: Int, bot: String, text: String) {
        let msg = ChatMessage(id: UUID(), botName: bot, message: text, timestamp: Date(), isUnread: false)
        chatManager.send(message: msg)
    }
    
    func markMessageAsRead(messageId: UUID?, inRoom room: String) {
        self.chatManager.markMessageAsRead(messageId: messageId, inRoom: room)
    }

    @MainActor
    func observeRoomsAndMessages(loader: Loader) {
        
        Task {  [weak self] in
            if loader == .center {
                self?.isLoading = true
            }
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
                self.isLoading = false
            } catch let error as APIError {
                self.apiError = error
                self.isLoading = false
            } catch let error {
                self.apiError = .custom(message: error.localizedDescription)
                self.isLoading = false
            }
        }
    }
}

//MARK: Helper Methods
extension ChatViewModel {
    private func observeMessages() {
        chatManager.roomsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newMessages in
                self?.chatMessages = newMessages
            }
            .store(in: &cancellables)
    }
}

//MARK: Delegate Methods
extension ChatViewModel: ChatManagerDelegate {
    func chatManager(didReceiveError error: Error) {
        DispatchQueue.main.async {
            self.apiError = .custom(message: error.localizedDescription)
        }
    }
}
