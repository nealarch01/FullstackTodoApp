//
//  HomeViewModel.swift
//  TodoApp
//
//  Created by Neal Archival on 1/15/23.
//

import Foundation
import SwiftUI

extension HomeView {
    @MainActor final class ViewModel: ObservableObject {
        @Published var userTodoLists: [TodoList]
        @Published var userTodoItems: [Todo]
        
        @Published var itemsColorMap: [UInt64:String]
        
        @Published var isListsLoading: Bool
        @Published var isItemsLoading: Bool
        
        @Published var listsErrorMessage: String
        @Published var itemsErrorMessage: String
        
        @Published var itemUpdated: Bool
        @Published var listUpdated: Bool
        
        @Published var showingAlert: Bool
        @Published var alertMessage: String
        
        init() {
            userTodoLists = []
            userTodoItems = []
            
            itemsColorMap = [:]
            
            isListsLoading = true
            isItemsLoading = true
            
            listsErrorMessage = ""
            itemsErrorMessage = ""
            
            itemUpdated = false
            listUpdated = false
            
            showingAlert = false
            alertMessage = ""
        }
        
        public func fetchUserTodoLists(token: String) -> Void {
            Task {
                isListsLoading = true
                let fetchResponse = await TodoService().getUserTodoLists(token: token)
                if fetchResponse.error != nil {
                    print("An error occured.")
                    print(fetchResponse.error!)
                    listsErrorMessage = fetchResponse.error!
                }
                userTodoLists = fetchResponse.data
                isListsLoading = false
                mapItemsColor()
            }
        }
        
        // Fetches all user's todo items (incomplete)
        public func fetchUserTodoItems(token: String) -> Void {
            Task {
                isItemsLoading = true
                let fetchResponse = await TodoService().getUserTodos(token: token)
                if fetchResponse.error != nil {
                    print("An error occured.")
                    print(fetchResponse.error!)
                    itemsErrorMessage = fetchResponse.error!
                }
                userTodoItems = fetchResponse.data
                isItemsLoading = false
            }
        }
        
        public func fetchUserData(token: String) -> Void {
            if token == "" { // If token is not present, do not make fetch
                // Additionally, when logout is clicked, the view will recall this function after the dismiss
                return
            }
            fetchUserTodoLists(token: token)
            fetchUserTodoItems(token: token)
        }
        
        public func toggleCompleted(todoID: UInt64, token: String) -> Void {
            Task {
                let httpResponse = await TodoService().toggleCompleted(todoID: todoID, token: token)
                if httpResponse.error != nil {
                    print("An error occured toggling completeness")
                    showingAlert = true
                    alertMessage = "An error occured updating. Try again."
                    return
                }
                for (index, todoItem) in userTodoItems.enumerated() {
                    if todoItem.id == todoID {
                        userTodoItems[index].completed = !userTodoItems[index].completed
                    }
                }
                // Push complete to the bottom
                sortCompleted()
            }
        }
        
        public func deleteTodo(todoID: UInt64, token: String) -> Void {
            Task {
                let httpResponse = await TodoService().deleteTodoItem(todoID: todoID, token: token)
                if httpResponse != nil { // If the response is nil, then no error message was returend
                    alertMessage = "Error deleting todo item. Try again"
                    showingAlert = true
                }
                // Successfully removed, remove from the array
                var index = 0
                for (i, todo) in userTodoItems.enumerated() {
                    if todo.id == todoID {
                        index = i
                    }
                }
                userTodoItems.remove(at: index)
            }
        }
        
        public func deleteList(listID: UInt64, token: String) -> Void {
            Task {
                let httpResponse = await TodoService().deleteTodoList(listID: listID, token: token)
                if httpResponse != nil {
                    alertMessage = httpResponse!
                    showingAlert = true
                    return
                }
                for (i, element) in userTodoLists.enumerated() {
                    if element.id == listID {
                        userTodoLists.remove(at: i)
                        break
                    }
                } // for
                for (i, element) in userTodoItems.enumerated() {
                    if element.listID == listID {
                        userTodoItems[i].listID = nil
                    }
                } // for
            }
        }
        
        
        
        
        // MARK: Helper functions
        public func mapItemsColor() -> Void {
            for todoList in userTodoLists {
                if itemsColorMap[todoList.id] != nil { // First time initialization
                    // Check if current color matches new
                    if todoList.color != itemsColorMap[todoList.id] { // Special case (when the page is refreshed)
                        itemsColorMap[todoList.id] = todoList.color
                    }
                    continue
                }
                print("Mapped list ID: \(todoList.id) with color: \(todoList.color)")
                itemsColorMap[todoList.id] = todoList.color
            }
        }
        
        public func getItemColor(listID: UInt64?) -> String {
            if listID == nil {
                return "#f1f1f1"
            }
            let color = itemsColorMap[listID!] ?? "#f1f1f1" // Return the default color
            return color // Not using one-liner for debugging purposes
        }
        
        public func sortCompleted() {
            userTodoItems.sort {
                return !($0.completed && !$1.completed)
            }
        }
        
    } // ViewModel
} // Extension
