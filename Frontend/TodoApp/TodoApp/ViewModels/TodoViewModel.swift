//
//  CreateTodoViewModel.swift
//  TodoApp
//
//  Created by Neal Archival on 1/20/23.
//

import Foundation

@MainActor class TodoViewModel: ObservableObject {
    @Published var title: String
    @Published var listID: UInt64?
    @Published var description: String
    @Published var priority: Int
    @Published var complete: Bool
    
    @Published var errorAlertShown: Bool
    @Published var errorMessage: String
    
    @Published var createComplete: Bool
    @Published var updateComplete: Bool
    
    init() {
        title = ""
        listID = nil
        description = ""
        priority = 0
        complete = false
        
        errorAlertShown = false
        errorMessage = ""
        
        createComplete = false
        updateComplete = false
    }
    
    public func createTodo(token: String) -> Void {
        if title == "" {
            errorMessage = "Error: title cannot be empty"
            errorAlertShown = true
            return
        }
        Task {
            let response = await TodoService().createTodoItem(
                title: self.title,
                description: description,
                listID: self.listID,
                priority: self.priority,
                token: token
            )
            if response.error != nil {
                errorMessage = response.error!
                errorAlertShown = true
                return
            }
            createComplete = true
        }
    }
    
    public func updateTodo(itemID: UInt64, token: String) -> Void {
        if title == "" {
            errorMessage = "Error: title cannot be empty"
            errorAlertShown = true
            return
        }
        // Create the new todo item object
        Task {
            let httpResponse = await TodoService().updateTodo(
                todoID: itemID,
                title: self.title,
                description: self.description,
                priority: self.priority,
                listID: self.listID,
                completed: self.complete,
                token: token
            )
            print("Finished updating")
            if httpResponse.error != nil || httpResponse.data == nil {
                errorMessage = httpResponse.error ?? "An error occured updating todo"
                errorAlertShown = true
                return
            }
            updateComplete = true
        }
    }
    
    public func deleteTodo(todoID: UInt64, token: String) -> Void {
        Task {
            let response = await TodoService().deleteTodoItem(todoID: todoID, token: token) // If the response is nil, then the request was successful
            // An error message will be returned from this function, nil means no errors
            if response != nil {
                errorAlertShown = true
                errorMessage = response!
                return
            }
            updateComplete = true
        }
    }
    
    
    
    
}
