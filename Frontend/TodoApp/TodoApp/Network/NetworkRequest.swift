//
//  NetworkRequests.swift
//  TodoApp
//
//  Created by Neal Archival on 1/17/23.
//

import Foundation

struct NetworkRequest {
    public func http<T: Decodable>(_ httpRequest: URLRequest, expectedType: T.Type) async -> (data: T?, error: String?) {
        do {
            let (responseData, urlResponse) = try await URLSession.shared.data(for: httpRequest)
            let httpUrlResponse = urlResponse as! HTTPURLResponse
            if httpUrlResponse.statusCode >= 400 {
                let apiError = try JSONDecoder().decode(APIError.self, from: responseData)
                return (nil, apiError.message) // Returns the error response
            }
            let decodedData = try JSONDecoder().decode(T.self, from: responseData)
            return (decodedData, nil)
        } catch let error {
            print(error.localizedDescription)
            return (nil, error.localizedDescription)
        }
    }
}
