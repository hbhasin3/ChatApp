//
//  ChatDetailView.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//


import SwiftUI

struct ChatDetailView: View {
    @ObservedObject var viewModel: ChatViewModel
    let selectedBot: String
    @State private var inputText: String = ""

    var body: some View {
        VStack {

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messagesForBot()) { msg in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(msg.message)
                                        .font(.body)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)

                                    Text(msg.timestamp, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                if msg.isQueued {
                                    Text("Queued")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                            .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    //Scroll to the last message on appear
                    if let last = viewModel.chatMessages[selectedBot]?.combinedMessages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.chatMessages[selectedBot]?.combinedMessages.count ?? 0) { _ in
                    if let last = messagesForBot().last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                    
                }
            }

            HStack {
                TextField("Message", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    viewModel.sendMessage(roomid: Int(selectedBot) ?? 0, bot: selectedBot, text: inputText)
                    inputText = ""
                }
                .disabled(inputText.isEmpty)
            }
            .padding()
        }
        .navigationTitle(selectedBot)
        .onAppear {
            markMessagesAsRead()
        }
    }

    private func messagesForBot() -> [ChatMessage] {
        viewModel.chatMessages.filter { $0.key == selectedBot }.first?.value.combinedMessages ?? []
    }

    private func markMessagesAsRead() {
        for i in viewModel.chatMessages.indices {
            if viewModel.chatMessages[i].key == selectedBot {
//                viewModel.chatMessages[i].value.receivedMessages.last?.markUnread()
            }
        }
    }
}
