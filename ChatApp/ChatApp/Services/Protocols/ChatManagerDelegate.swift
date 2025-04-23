//
//  ChatManagerDelegate.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 24/04/25.
//


protocol ChatManagerDelegate: AnyObject {
    func chatManager(didReceiveError error: Error)
}
