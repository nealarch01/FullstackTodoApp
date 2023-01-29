//
//  ProfileView.swift
//  TodoApp
//
//  Created by Neal Archival on 1/26/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: Session
    var body: some View {
        ZStack {
            Color.offWhite
                .ignoresSafeArea([.all])
            VStack(spacing: 20) {
                Image(systemName: "person")
                    .font(.system(size: 100))
                
                Button(action: {}) {
                    Text("Update email")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color.white)
                        .frame(width: 200, height: 60)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }

                Button(action: {}) {
                    Text("Update Password")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color.white)
                        .frame(width: 240, height: 60)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                
                Button(action: session.unsetToken) {
                    Text("Logout")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color.white)
                        .frame(width: 150, height: 60)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                Spacer()
            } // VStack
        } // ZStack
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(Session(customToken: ""))
        }
    }
}
