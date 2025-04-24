//
//  MessageView.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 25/04/25.
//

import SwiftUI

struct MessageView: View {
    
    var msg: ChatMessage
    
    var body: some View {
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

            
                Text(msg.isQueued ? "Queued" : "Sent")
                    .font(.caption2)
                    .foregroundColor(msg.isQueued ? .orange : .green)
            
        }
        .id(msg.id)
    }
}

#Preview {
    MessageView(msg: ChatMessage(botName: "SponserBot", message: "Hi"))
}
