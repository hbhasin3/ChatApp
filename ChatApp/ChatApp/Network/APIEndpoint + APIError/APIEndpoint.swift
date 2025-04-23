//
//  APIEndpoint.swift
//  NetworkConnection
//
//  Created by GrandGaming.com.
//

import Foundation
import UIKit

public protocol APIRequest {
    var url: URL? { get }
    var path: String { get }
    
    var headers: [String: String]? { get }
    var baseHeader: [String: String] { get }
    
}

enum APIEndpoint {
    
    enum current: APIRequest {
        case getActiveRooms
        
        var path: String {
            switch self {
            case .getActiveRooms:
                return "connections"
            }
        }
        
        var baseHeader: [String: String] {
            return  ["Content-Type": "application/json"]
        }
        
        var headers: [String: String]? {
            var allHeaders = baseHeader
            switch self {
            case .getActiveRooms:
                allHeaders["key"] = AppEnvironment.apiKey
                allHeaders["secret"] = AppEnvironment.apiSecret
                break
            }
            return allHeaders
        }
        var url: URL? {
            return URL(string: baseURL + path)
        }

        var baseURL: String {
            return AppEnvironment.baseURL
        }
    }
    
    
    enum mock: APIRequest {
        case getActiveRooms
        
        var path: String {
            switch self {
            case .getActiveRooms:
                return "connections"
            }
        }
        var baseHeader: [String: String] {
            return  ["Content-Type": "application/json"]
        }
        var headers: [String: String]? {
            var allHeaders = baseHeader
            switch self {
            case .getActiveRooms:
                allHeaders["key"] = AppEnvironment.apiKey
                allHeaders["secret"] = AppEnvironment.apiSecret
                break
            }
            return allHeaders
        }
        var url: URL? {
            return URL(string: baseURL + path)
        }

        var baseURL: String {
            return "https://08f1dce0-99e2-40dc-937f-f1690da10142.mock.pstmn.io/"
        }
    }
    
}
