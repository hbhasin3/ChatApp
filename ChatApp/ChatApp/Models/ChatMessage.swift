//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//

import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let botName: String
    let message: String
    let timestamp: Date
    var isUnread: Bool
    var isQueued: Bool = false
    
    init(id: UUID = UUID(), botName: String, message: String, timestamp: Date = Date(), isUnread: Bool = true, isQueued: Bool = false) {
        self.id = id
        self.botName = botName
        self.message = message
        self.timestamp = timestamp
        self.isUnread = isUnread
        self.isQueued = isQueued
    }
}

