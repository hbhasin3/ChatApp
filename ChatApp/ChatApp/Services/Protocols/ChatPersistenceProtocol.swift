//
//  ChatPersistenceProtocol.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//
import Foundation

protocol ChatPersistenceProtocol {
    func save(_ messages: [ChatMessage], forRoom room: String)
    func load(forRoom room: String) -> [ChatMessage]
}
