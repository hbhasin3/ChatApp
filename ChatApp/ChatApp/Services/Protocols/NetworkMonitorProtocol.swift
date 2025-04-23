//
//  NetworkMonitorProtocol.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//
import Foundation

protocol NetworkMonitorProtocol: ObservableObject {
    var isConnected: Bool { get }
}
