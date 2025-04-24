//
//  RoomView.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 25/04/25.
//

import SwiftUI

struct RoomView: View {
    
    @ObservedObject var viewModel: ChatViewModel
    var bot: String
    
    var body: some View {
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
    
    private func lastMessage(for bot: String) -> ChatMessage? {
        viewModel.chatMessages.filter { $0.key == bot }.first?.value.combinedMessages.last
    }

    private func hasUnreadMessages(bot: String) -> Bool {
        viewModel.chatMessages.contains { $0.key == bot && $0.value.combinedMessages.last?.isUnread ?? false }
    }
}

#Preview {
    RoomView(viewModel: ChatViewModel(), bot: "SupportBot")
}
