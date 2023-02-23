//
//  AuthView.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import SwiftUI



struct LoginView: View {
    @EnvironmentObject private var session: Session
    @ObservedObject var authViewModel: AuthViewModel
    @State private var isLoading: Bool = false
    var body: some View {
        VStack {
            VStack {
                Text("Todo App")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding([.bottom], 15)
            } // VStack
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            VStack {
                HStack {
                    Text("Sign In")
                        .font(.system(size: 34, weight: .bold))
                } // HStack
                .padding([.leading], 20)
                .padding([.bottom], 5)
                HStack {
                    Text("Username")
                        .font(.system(size: 24, weight: .medium))
                    Spacer()
                } // HStack
                .padding([.leading], 20)
                TextInput(input: $authViewModel.loginForm.userIdentifier, placeholder: "Enter username or email")
                    .padding([.top], -10)
                
                HStack {
                    Text("Password")
                        .font(.system(size: 24, weight: .medium))
                    Spacer()
                } // HStack
                .padding([.leading], 20)
                .padding([.top], 8)
                SecuredTextInput(input: $authViewModel.loginForm.password, placeholder: "Enter password")
                    .padding([.top], -10)
                
                GeometryReader { geometry in
                    Button(action: loginClicked) {
                        Text("Login")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.white)
                            .frame(width: geometry.size.width * 0.6, height: 60)
                            .background(Color.blue)
                            .cornerRadius(12)
                    } // HStack
                    .frame(width: geometry.size.width, height: 60)
                } // GeometryReader
                .frame(height: 60)
                .padding([.top], 18)
                
                if authViewModel.loginError != "" {
                    Text("\(authViewModel.loginError)")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color.red)
                        .padding([.top], 10)
                }
                
                HStack(spacing: 0) {
                    Text("Don't have an account?")
                    Button(action: {
                        authViewModel.currentScreen = .Register
                    }) {
                        Text(" Sign in")
                    } // Button
                } // HStack
                .font(.system(size: 22, weight: .medium))
                .padding([.top], 10)
            } // VStack
            Spacer()
        } // VStack
    } // Body
    
    private func loginClicked() -> Void {
        Task {
            let token = await authViewModel.login()
            if token == "" {
                return
            }
            session.setToken(token)
        }
        
    }
}

struct RegisterView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @EnvironmentObject private var session: Session
    var body: some View {
        VStack {
            VStack {
                Text("Todo App")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(Color.white)
                    .padding([.bottom], 15)
            }
            .frame(maxWidth: .infinity)
            .background(Color.blue)

            VStack {
                HStack {
                    Text("Create Account")
                        .font(.system(size: 34, weight: .bold))
                } // HStack
                .padding([.leading], 20)
                .padding([.bottom], 5)
                
                HStack {
                    Text("Email Address")
                        .font(.system(size: 24, weight: .medium))
                    Spacer()
                } // HStack
                .padding([.leading], 20)
                TextInput(input: $authViewModel.registerForm.email, placeholder: "Enter email")
                    .padding([.top], -10)
                
                HStack {
                    Text("Username")
                        .font(.system(size: 24, weight: .medium))
                    Spacer()
                } // HStack
                .padding([.leading], 20)
                TextInput(input: $authViewModel.registerForm.username, placeholder: "Enter username")
                    .padding([.top], -10)
                
                HStack {
                    Text("Password")
                        .font(.system(size: 24, weight: .medium))
                    Spacer()
                } // HStack
                .padding([.leading], 20)
                SecuredTextInput(input: $authViewModel.registerForm.password, placeholder: "Enter password")
                    .padding([.top], -10)
            } // VStack
            
            GeometryReader { geometry in
                Button(action: registerClicked) {
                    Text("Register")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(width: geometry.size.width * 0.6, height: 60)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                } // HStack
                .frame(width: geometry.size.width, height: 60)
            }
            .frame(height: 60)
            .padding([.top], 18)
            
            if authViewModel.registerError != "" {
                Text("\(authViewModel.registerError)")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Color.red)
                    .padding([.top], 10)
            }
            
            HStack(spacing: 0) {
                Text("Already have an account?")
                Button(action: {
                    authViewModel.currentScreen = .Login
                }) {
                    Text("Login")
                } // Button
            } // HStack
            .font(.system(size: 22, weight: .medium))
            .padding([.top], 10)
            
            Spacer()
            
        } // VStack
    } // View
    
    private func registerClicked() -> Void {
        Task {
            let token = await authViewModel.register()
            if token == "" {
                return
            }
            session.setToken(token)
        }
    }
}

struct AuthView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @EnvironmentObject private var session: Session
    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea([.all])
            if authViewModel.currentScreen == .Login {
                LoginView(authViewModel: authViewModel)
            } else {
                RegisterView(authViewModel: authViewModel)
            }
        }
    } // View
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(Session())
    }
}
