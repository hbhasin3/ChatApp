//
//  ChatAppApp.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//

import SwiftUI

@main
struct ChatAppApp: App {

    var body: some Scene {
        WindowGroup {
            let viewModel = ChatViewModel()
            ChatListView(viewModel: viewModel)
        }
    }
}
