//
//  AppContainer.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//


struct AppContainer {
    static let shared = AppContainer()

    let viewModel: ChatViewModel

    private init() {
        let persistence = ChatPersistenceService.shared
        let networkMonitor = NetworkMonitor()
        let chatManager = ChatManager()
        
        self.viewModel = ChatViewModel(
            persistenceService: persistence,
            networkMonitor: networkMonitor,
            chatManager: chatManager
        )
    }
}
