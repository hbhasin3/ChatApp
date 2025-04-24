//
//  ChatListView.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//
import SwiftUI

struct ChatListView: View {
    @StateObject var viewModel: ChatViewModel
    @State private var selectedBot: String?


    var body: some View {
        NavigationView {
            LoadingView(isShowing: $viewModel.isLoading) {
                List {
                    ForEach(botNames(), id: \.self) { bot in
                        NavigationLink(destination: ChatDetailView(viewModel: viewModel, selectedBot: bot), tag: bot, selection: $selectedBot) {
                            RoomView(viewModel: self.viewModel, bot: bot)
                        }
                        .onChange(of: selectedBot) { oldValue, newValue in
                            viewModel.markMessageAsRead(messageId: lastMessage(for: bot)?.id, inRoom: bot)
                        }
                        
                    }
                }
                .refreshable {
                    Task {
                        self.viewModel.observeRoomsAndMessages(loader: .refresh)
                    }
                }
                .navigationTitle("Chats")
                .alert(item: $viewModel.apiError) { error in
                    Alert(
                        title: Text("Error"),
                        message: Text(error.localizedDescription),
                        dismissButton: .default(Text("OK")) {
                            viewModel.apiError = nil // reset
                        }
                    )
                }
            }
        }
    }

    private func botNames() -> [String] {
        Set(viewModel.chatMessages.map { $0.key }).sorted()
    }
    
    private func lastMessage(for bot: String) -> ChatMessage? {
        viewModel.chatMessages.filter { $0.key == bot }.first?.value.combinedMessages.last
    }
}


