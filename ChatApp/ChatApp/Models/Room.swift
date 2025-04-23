//
//  Rooms.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 23/04/25.
//

import Foundation

struct Room: Identifiable, Codable, Hashable {
    let id: UUID = UUID()
    let room_id: Int
    let channel_id: Int
    let connection_count: Int
    
}


