//
//  ChatProtocol.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 23/04/25.
//
import Foundation

protocol ChatProtocol {
    func connectToRoom(_ roomName: String, channelId: String)
    func send(message: ChatMessage)
    func messages(for roomName: String) -> [ChatMessage]
    func disconnectRoom(_ roomName: String)
    func disconnectAll()
    func markMessageAsRead(messageId: UUID?, inRoom room: String)
    
    var roomsPublisher: Published<[String: PieSocketRoomClient]>.Publisher { get }
    var delegate: ChatManagerDelegate? { get set }
}
