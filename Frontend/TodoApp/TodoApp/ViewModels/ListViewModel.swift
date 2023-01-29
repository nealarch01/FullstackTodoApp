//
//  ListViewModel.swift
//  TodoApp
//
//  Created by Neal Archival on 1/26/23.
//

import Foundation

@MainActor class ListViewModel: ObservableObject {
    @Published var name: String
    @Published var color: String
    
    @Published var errorAlertShown: Bool
    @Published var errorMessage: String
    
    @Published var createComplete: Bool
    @Published var updateComplete: Bool
    
    init() {
        name = ""
        color = ""
        
        errorAlertShown = false
        errorMessage = ""
        
        createComplete = false
        updateComplete = false
    }
    
    public func createList(token: String) -> Void {
        if name == "" {
            errorMessage = "Name cannot be empty"
            errorAlertShown = true
            return
        }
        Task {
            let httpResponse = await TodoService().createTodoList(name: self.name, color: self.color, token: token)
            print("Completed http response")
            if httpResponse.error != nil {
                errorMessage = httpResponse.error!
                errorAlertShown = true
                return
            }
            // No need to parse through httpResponse.data
            createComplete = true
        }
    }
    
    public func updateList(listID: UInt64, token: String) -> Void {
        if name == "" {
            errorMessage = "Name cannot be empty"
            errorAlertShown = true
            return
        }
        Task {
            let httpResponse = await TodoService().updateTodoList(name: self.name, color: self.color, listID: listID, token: token)
            if httpResponse.error != nil {
                errorMessage = httpResponse.error!
                errorAlertShown = true
                return
            }
            updateComplete = true
        }
    }
    
    public func deleteList(listID: UInt64, token: String) -> Void {
        Task {
            let httpResponse = await TodoService().deleteTodoList(listID: listID, token: token)
            if httpResponse != nil {
                errorAlertShown = true
                errorMessage = httpResponse!
                return
            }
            updateComplete = true
        }
    }
    
}
