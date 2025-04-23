//
//  ActiveRoomsService.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//
import Foundation
import Combine

class ActiveRoomsService: ActiveRoomProtocol, ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let networkService: NetworkServiceprotocol
    @Published private(set) var rooms: [Room] = []
    

    init(networkService: NetworkServiceprotocol = NetworkRepository()) {
        self.networkService = networkService
    }

    
    func loadRooms() async throws -> Result<[Room], APIError> {
        return try await getActiveRooms()
    }
    
    private func getActiveRooms() async throws -> Result<[Room], APIError> {
        do {
            let rooms = try await networkService.getData(from: APIEndpoint.current.getActiveRooms, model: [Room].self)
            return rooms
        } catch let error as APIError {
            return .failure(error)
        } catch let error {
            print(error)
            return .failure(.custom(message: error.localizedDescription))
        }
        
    }
}
