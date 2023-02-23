//
//  TodoApp.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import SwiftUI

@main
struct TodoApp: App {
    @StateObject private var session = Session()
    @State private var isLoading: Bool = true
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .overlay {
                    if isLoading {
                        ZStack {
                            Color.offWhite
                                .ignoresSafeArea([.all])
                        }
                    }
                }
                .onAppear {
                    checkSavedLogin()
                }
        }
    }
    
    private func checkSavedLogin() {
        print("Checking if credentials exist")
        defer {
            isLoading = false
        }
        isLoading = true
        guard let token = session.lastSavedToken() else {
            return
        }
        if token == "" {
            session.unsetToken()
            return
        }
        // Do an HTTP request to check if the token is valid
        Task {
            let verificationError = await AuthService().verifyToken(token: token)
            if verificationError != nil {
                print(verificationError!)
                session.unsetToken() // Sets to an empty string
                return
            }
            session.setToken(token)
        } // End of Task Block
    }
}
