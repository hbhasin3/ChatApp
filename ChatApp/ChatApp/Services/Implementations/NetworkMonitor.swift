//
//  NetworkMonitor.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//

import Foundation
import Network

final class NetworkMonitor: NetworkMonitorProtocol {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private(set) var isConnected: Bool = true {
        didSet {
            if oldValue != isConnected {
                print("Network status changed: \(isConnected)")
                DispatchQueue.main.async {
                    self.onStatusChange?(self.isConnected)
                }
            }
        }
    }

    var onStatusChange: ((Bool) -> Void)?

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let newStatus = path.status == .satisfied
            self.isConnected = newStatus
        }

        monitor.start(queue: queue)
        print("Started network monitoring")
    }

    func stopMonitoring() {
        monitor.cancel()
        onStatusChange = nil
    }
}
