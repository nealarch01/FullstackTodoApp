//
//  AuthViewModel.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import Foundation

class LoginForm: ObservableObject {
    @Published var userIdentifier: String
    @Published var password: String
    
    init() {
        userIdentifier = ""
        password = ""
    }
}

class RegisterForm: ObservableObject {
    @Published var username: String
    @Published var email: String
    @Published var password: String
    private var regexTester: RegexTester
    
    init() {
        username = ""
        email = ""
        password = ""
        regexTester = RegexTester()
    }
    
    // Returns nil if username is valid
    func verifyUsername() -> String? {
        if username.count < 3 {
            return "Username mus tbe at least 3 characters long."
        }
        if !regexTester.verifyUsername(self.username) {
            return "Invalid username. Must contain at least one letter and can include letters, numbers, periods, underscores, and dashes. Special characters must be followed by a letter or number."
        }
        return nil
    }
    
    func verifyPassword() -> String? {
        if password.count < 8 {
            return "Password must be 8 characters long"
        }
        if !regexTester.verifyPassword(self.password) {
            return "Invalid password. Must contain one uppercase and lowercase character, a number, and special character such as (!@#$%^&*)"
        }
        return nil
    }
    
    func verifyEmail() -> String? {
        if !regexTester.verifyEmail(self.email) {
            return "Invalid email. Use a valid email or try another one"
        }
        return nil
    }
    
}

enum AuthScreens {
    case Login
    case Register
}

@MainActor class AuthViewModel: ObservableObject {
    @Published var registerForm: RegisterForm
    @Published var loginForm: LoginForm
    @Published var currentScreen: AuthScreens
    @Published var loginError: String = ""
    @Published var registerError: String = ""

    init() {
        registerForm = RegisterForm()
        loginForm = LoginForm()
        currentScreen = .Login
    }
    
    public func login() async -> String {
        let (token, error) = await AuthService().login(userIdentifier: loginForm.userIdentifier, password: loginForm.password)
        if error != nil {
            loginError = error!
            return ""
        }
        return token
    }
    
    public func register() async -> String {
        let (token, error) = await AuthService().register(username: registerForm.username, email: registerForm.email, password: registerForm.password)
        if error != nil {
            registerError = error!
            return ""
        }
        return token
    }
    
}
