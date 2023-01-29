//
//  ContentView.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: Session
    var body: some View {
        if session.token == "" {
            AuthView()
        } else {
            HomeView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Session())
    }
}
