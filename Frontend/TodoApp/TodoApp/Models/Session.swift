//
//  Session.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import Foundation

class Session: ObservableObject {
    @Published private(set) var token: String
    
    init() {
        self.token = ""
    }
    
    init(customToken: String) {
        self.token = customToken
    }
    
    public func setToken(_ token: String) {
        self.token = token
        saveJWT(token: token)
    }
    
    public func unsetToken() {
        // Also unset the token saved in keychain
        saveJWT(token: "")
        self.token = ""
    }
}
