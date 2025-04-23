//
//  PieSocketRoomClientDelegate.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 24/04/25.
//


protocol PieSocketRoomClientDelegate: AnyObject {
    func pieSocketClient(didReceiveError error: Error)
}
