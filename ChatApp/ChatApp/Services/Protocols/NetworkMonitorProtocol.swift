//
//  NetworkMonitorProtocol.swift
//  ChatApp
//
//  Created by Harsh Bhasin on 22/04/25.
//
import Foundation

protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    var onStatusChange: ((Bool) -> Void)? { get set }
    func startMonitoring()
    func stopMonitoring()
}
