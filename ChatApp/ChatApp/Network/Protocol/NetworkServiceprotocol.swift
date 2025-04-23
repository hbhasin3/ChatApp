//
//  NetworkServiceprotocol.swift
//  NetworkConnection
//
//  Created by GrandGaming.com.
//

import Foundation
import UIKit
import Combine

protocol NetworkServiceprotocol {
    func fetchData<T: Decodable>(with request: URLRequest, model: T.Type) async throws -> Result<T, APIError>
}

extension NetworkServiceprotocol {
    
    func getData<T: Codable>(
        from endpoint: APIRequest,
        model: T.Type,
        queryParam: [URLQueryItem]? = nil) async throws  -> Result<T, APIError> {
            guard let url = endpoint.url else {
                return .failure(.invalidURL)
            }
            var request = URLRequest(url: url)
            request.httpMethod =  HTTPMethods.get.rawValue
            request.allHTTPHeaderFields = endpoint.headers
            do {
                return try await fetchData(with: request, model: model)
            } catch let error as APIError {
                return .failure(error)
            } catch let error {
                print(error)
                return .failure(.custom(message: error.localizedDescription))
            }
        }
    
}

class NetworkRepository: NetworkServiceprotocol {
    
    internal func fetchData<T: Decodable>(with request: URLRequest,
                                          model: T.Type) async throws -> Result<T, APIError> {
        let session = URLSession.shared
        Log.d("API request url: \(String(describing: request.url))")
        Log.d("API request body: \(String(describing: request.httpBody))")
        Log.d("API request method: \(String(describing: request.httpMethod))")
        Log.d("API request header: \(String(describing: request.allHTTPHeaderFields))")
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                return .failure(.httpError(statusCode: httpResponse.statusCode))
            }
            
            let dict = try? JSONSerialization.jsonObject(with: data, options: [])
            let jsonbody = try! JSONSerialization.data(withJSONObject: dict as? [String:Any] ?? [:], options: [.prettyPrinted])
            Log.log(Type: model.self, response: httpResponse, data: jsonbody)
            let decodedObject = try JSONDecoder().decode(model, from: data)
            
            return .success(decodedObject)
        } catch let error as APIError {
            return .failure(error)
        } catch let error {
            print(error)
            return .failure(.custom(message: error.localizedDescription))
        }
        
    }
    
    
}
