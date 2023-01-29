//
//  NetworkManager.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import Foundation

struct AuthService {
    fileprivate let authEndpoint: String = "http://localhost:6001/auth"
    
    public func login(userIdentifier: String, password: String) async -> (token: String, error: String?) {
        let loginEndpoint = authEndpoint + "/login"
        var httpRequest = URLRequest(url: URL(string: loginEndpoint)!)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestBody = URLComponents()
        requestBody.queryItems = []
        requestBody.queryItems!.append(URLQueryItem(name: "user_identifier", value: userIdentifier))
        requestBody.queryItems!.append(URLQueryItem(name: "password", value: password))
        httpRequest.httpBody = requestBody.query!.data(using: .utf8)
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: AuthResponse.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return ("", httpResponse.error ?? "An error occured. Could not obtain/decode token")
        }
        return (httpResponse.data!.token, nil)
    }
    
    public func register(username: String, email: String, password: String) async -> (token: String, error: String?) {
        let registerEndpoint = authEndpoint + "/register"
        var httpRequest = URLRequest(url: URL(string: registerEndpoint)!)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestBody = URLComponents()
        requestBody.queryItems = []
        requestBody.queryItems!.append(URLQueryItem(name: "username", value: username))
        requestBody.queryItems!.append(URLQueryItem(name: "email", value: email))
        requestBody.queryItems!.append(URLQueryItem(name: "password", value: password))
        httpRequest.httpBody = requestBody.query!.data(using: .utf8)
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: AuthResponse.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return ("", httpResponse.error ?? "An error occured. Could not obtain/decode user tokens")
        }
        return (httpResponse.data!.token, nil)
    }
    
    func refresh(token: String) -> (token: String, error: String?) {
        return ("", "An error occured attempting to refresh")
        // Check if the JWT is online
    }
    
    // Returns an error message
    func verifyToken(token: String) async -> String? {
        struct ResponseSchema: Decodable {
            var message: String
        }
        let endpoint = authEndpoint + "/token/verify"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        if httpResponse.error != nil {
            return httpResponse.error
        }
        return nil
    }
    
    // TODO: Implement this function to send an HTTP request to blacklist the token
    func logout(token: String) async -> Void {
        return
    }
    
}

