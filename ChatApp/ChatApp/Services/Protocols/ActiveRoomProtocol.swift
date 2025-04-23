//
//  ActiveRoomProtocol.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//

import Foundation

protocol ActiveRoomProtocol: AnyObject {
    func loadRooms() async throws -> Result<[Room], APIError> 
}
