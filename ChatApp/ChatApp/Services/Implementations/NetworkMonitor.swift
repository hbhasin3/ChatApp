//
//  NetworkMonitor.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//
import Network
import Foundation


class NetworkMonitor: NetworkMonitorProtocol {
    @Published private(set) var isConnected: Bool = true
    private var monitor = NWPathMonitor()

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: .main)
        
    }
}
