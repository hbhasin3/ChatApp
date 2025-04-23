//
//  AppEnvironment.swift
//
//  Created by Harsh Bhasin on 22/10/24.
//

import Foundation

public enum AppEnvironment {
    case production
    case staging
}

public extension AppEnvironment {
    static var currentState: AppEnvironment {
//        #if STAGING
//                return .staging
//        #else
                return .production
//        #endif
    }
    
    static var baseURL: String {
        switch AppEnvironment.currentState {
        case .production:
            return URLConfiguration.production
        case .staging:
            return URLConfiguration.staging
        }
    }
    
    static var clusterID: String {
        switch AppEnvironment.currentState {
        case .production:
            return "s14494.blr1"
        case .staging:
            return "s14494.blr1"
        }
    }
    
    static var apiKey: String {
        switch AppEnvironment.currentState {
        case .production:
            return "aB6I0jEy6heyaUG4DWGlytAr9i52TwmuVUZnD5L2"
        case .staging:
            return "aB6I0jEy6heyaUG4DWGlytAr9i52TwmuVUZnD5L2"
        }
    }
    
    static var apiSecret: String {
        switch AppEnvironment.currentState {
        case .production:
            return "BDP3Vo187nfXTIHVr6N39I3Q8shr7TYm"
        case .staging:
            return "BDP3Vo187nfXTIHVr6N39I3Q8shr7TYm"
        }
    }

}
