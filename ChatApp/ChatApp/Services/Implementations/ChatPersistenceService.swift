//
//  ChatPersistenceService.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//
import Foundation


final class ChatPersistenceService: ChatPersistenceProtocol {
    static let shared = ChatPersistenceService()

    private init() {}
    
    private func fileURL(forRoom room: String) -> URL {
        let filename = "chat_\(room).json"
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    func save(_ messages: [ChatMessage], forRoom room: String) {
        do {
            let data = try JSONEncoder().encode(messages)
            try data.write(to: fileURL(forRoom: room))
        } catch {
            print("Save error for \(room): \(error)")
        }
    }

    func load(forRoom room: String) -> [ChatMessage] {
        let url = fileURL(forRoom: room)
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([ChatMessage].self, from: data)) ?? []
    }
}

//final class UnsentMessageStorage {
//    static let shared = UnsentMessageStorage()
//    
//    private init() {}
//
//    private func fileURL(forRoom room: String) -> URL {
//        let fileName = "unsent_\(room).json"
//        return FileManager.default
//            .urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent(fileName)
//    }
//
//    func save(_ messages: [ChatMessage], forRoom room: String) {
//        do {
//            let data = try JSONEncoder().encode(messages)
//            try data.write(to: fileURL(forRoom: room))
//        } catch {
//            print("Failed to save unsent messages: \(error)")
//        }
//    }
//
//    func load(forRoom room: String) -> [ChatMessage] {
//        let url = fileURL(forRoom: room)
//        guard let data = try? Data(contentsOf: url) else { return [] }
//        return (try? JSONDecoder().decode([ChatMessage].self, from: data)) ?? []
//    }
//
//    func clear(forRoom room: String) {
//        try? FileManager.default.removeItem(at: fileURL(forRoom: room))
//    }
//}

