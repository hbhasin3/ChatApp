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
            List {
                ForEach(botNames(), id: \.self) { bot in
                    NavigationLink(destination: ChatDetailView(viewModel: viewModel, selectedBot: bot), tag: bot, selection: $selectedBot) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(bot)
                                    .font(.headline)
                                if let last = lastMessage(for: bot) {
                                    Text(last.message)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            if hasUnreadMessages(bot: bot) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 10, height: 10)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onChange(of: selectedBot) { oldValue, newValue in
                        viewModel.markMessageAsRead(messageId: lastMessage(for: bot)?.id, inRoom: bot)
                    }
                    
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

    private func botNames() -> [String] {
        Set(viewModel.chatMessages.map { $0.key }).sorted()
    }

    private func lastMessage(for bot: String) -> ChatMessage? {
        viewModel.chatMessages.filter { $0.key == bot }.first?.value.combinedMessages.last
    }

    private func hasUnreadMessages(bot: String) -> Bool {
        viewModel.chatMessages.contains { $0.key == bot && $0.value.combinedMessages.last?.isUnread ?? false }
    }
}


