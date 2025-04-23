//
//  APIError.swift
//  NetworkConnection
//
//

import Foundation

public enum APIError: Error, Identifiable {
    case invalidURL
    case requestFailed(error: String)
    case invalidResponse
    case httpError(statusCode: Int)
    case noData
    case decodingError
    case encodingError
    case invalidToken
    case custom(message: String)
    
    public var id: String { localizedDescription }
    
    // Add more cases as needed for your specific API errors
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let error):
            return "Request failed \(error)"
        case .invalidResponse:
            return "Invalid response from the server."
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)."
        case .noData:
            return "No data received from the server."
        case .decodingError:
            return "Error decoding the response data."
        case .encodingError:
            return "Error encoding the request data."
        case .invalidToken:
            return "Invalid token"
        case .custom(let message):
            return message
        // Add localized descriptions for other cases
        }
    }
}

public enum HTTPStatusCode: Int {
    case success = 200
    case created = 201
    case noContent = 204
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case serverError = 500
    // Add more status codes as needed

    var description: String {
        switch self {
        case .success:
            return "Success"
        case .created:
            return "Created"
        case .noContent:
            return "No Content"
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not Found"
        case .serverError:
            return "Server Error"
        // Add descriptions for other cases
        }
    }
}
