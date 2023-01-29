//
//  TodoService.swift
//  TodoApp
//
//  Created by Neal Archival on 1/10/23.
//

import Foundation

struct TodoService {
    private let todoEndpoint = "http://localhost:6001/todo"
    // MARK: -- Todo Lists
    
    // MARK: getUserTodoLists
    public func getUserTodoLists(token: String) async -> (data: [TodoList], error: String?) {
        struct ResponseSchema: Decodable {
            var todo_lists: [TodoList]
        }
        let endpoint = todoEndpoint + "/lists"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "GET"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return ([], httpResponse.error ?? "An error occured. Could not obtain/decode user todo lists")
        }
        return (httpResponse.data!.todo_lists, nil)
    }
    
    // MARK: createTodoList
    public func createTodoList(name: String, color: String, token: String) async -> (data: TodoList?, error: String?) {
        struct ResponseSchema: Decodable {
            var message: String
            var todo_list: TodoList
        }
        let endpoint = todoEndpoint + "/list"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        httpRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestBody = URLComponents()
        requestBody.queryItems = []
        requestBody.queryItems!.append(URLQueryItem(name: "name", value: name))
        requestBody.queryItems!.append(URLQueryItem(name: "color", value: color))
        httpRequest.httpBody = requestBody.query!.data(using: .utf8)
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return (nil, httpResponse.error ?? "An error occured. Could not obtain/decode newly created list")
        }
        return (httpResponse.data!.todo_list, nil)
    }
    
    // MARK: updateTodoList
    public func updateTodoList(name: String, color: String, listID: UInt64, token: String) async -> (data: TodoList?, error: String?) {
        struct ResponseSchema: Decodable {
            var message: String
            var todo_list: TodoList
        }
        let endpoint = todoEndpoint + "/list/\(listID)"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "PUT"
        httpRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        var requestBody = URLComponents()
        requestBody.queryItems = []
        requestBody.queryItems!.append(URLQueryItem(name: "name", value: name))
        requestBody.queryItems!.append(URLQueryItem(name: "color", value: color))
        httpRequest.httpBody = requestBody.query!.data(using: .utf8)
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return (nil, httpResponse.error ?? "An error occured. Could not create todo list")
        }
        return (httpResponse.data!.todo_list, nil)
    }
    
    // MARK: deleteTodoList
    public func deleteTodoList(listID: UInt64, token: String) async -> String? {
        struct ResponseSchema: Decodable {
            var message: String
        }
        let endpoint = todoEndpoint + "/list/\(listID)"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "DELETE"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse.error == nil else {
            return httpResponse.error ?? "An error occured deleting"
        }
        return nil
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: -- TodoItems
    public func getTodoItemsInList(listID: String, token: String) async -> (data: [Todo], error: String?) {
        struct ResponseSchema: Decodable {
            var todo_items: [Todo]
        }
        let endpoint = todoEndpoint + "/list/\(listID)/items"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "GET"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return ([], httpResponse.error ?? "An error occured. Could not fetch user todo lists")
        }
        return (httpResponse.data!.todo_items, nil)
    }
    
    // MARK: createTodoItem
    public func createTodoItem(title: String, description: String?, listID: UInt64?, priority: Int, token: String) async -> (data: Todo?, error: String?) {
        struct ResponseSchema: Decodable {
            var todo_item: Todo
        }
        let endpoint = todoEndpoint + "/item"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        httpRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestBody = URLComponents()
        requestBody.queryItems = [] // Set to an array since it is nil by default
        // Essential form parameters is just title
        requestBody.queryItems!.append(URLQueryItem(name: "title", value: title))
        requestBody.queryItems!.append(URLQueryItem(name: "description", value: description ?? "null"))
        requestBody.queryItems!.append(URLQueryItem(name: "list_id", value: listID != nil ? "\(listID!)" : "null"))
        httpRequest.httpBody = requestBody.query!.data(using: .utf8)
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return (nil, httpResponse.error ?? "An error occured creating todo item")
        }
        return (nil, nil)
    }
    
    // MARK: toggleCompleted
    public func toggleCompleted(todoID: UInt64, token: String) async -> (data: Todo?, error: String?) {
        struct ResponseSchema: Decodable {
            var message: String
            var todo_item: Todo
        }
        let endpoint = todoEndpoint + "/item/complete/\(todoID)"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "PUT"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return (nil, httpResponse.error ?? "An error occured updating completion status")
        }
        return (httpResponse.data!.todo_item, nil)
    }
    
    // MARK: getUserTodos
    public func getUserTodos(token: String) async -> (data: [Todo], error: String?) {
        struct ResponseSchema: Decodable {
            var todo_items: [Todo]
        }
        let endpoint = todoEndpoint + "/items"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "GET"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return ([], httpResponse.error ?? "An error occured. Could not obtain/decode user todo lists")
        }
        return (httpResponse.data!.todo_items, nil)
    }
    
    // MARK: updateTodo
    public func updateTodo(todoID: UInt64, title: String, description: String, priority: Int, listID: UInt64?, completed: Bool, token: String) async -> (data: Todo?, error: String?) {
        struct ResponseSchema: Decodable {
            var message: String
            var todo_item: Todo
        }
        let endpoint = todoEndpoint + "/item/\(todoID)"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "PUT"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        httpRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestBody = URLComponents()
        requestBody.queryItems = []
        requestBody.queryItems!.append(URLQueryItem(name: "title", value: title))
        requestBody.queryItems!.append(URLQueryItem(name: "description", value: description))
        requestBody.queryItems!.append(URLQueryItem(name: "priority", value: "\(priority)"))
        requestBody.queryItems!.append(URLQueryItem(name: "list_id", value: listID != nil ? "\(listID!)" : "null"))
        requestBody.queryItems!.append(URLQueryItem(name: "completed", value: completed == true ? "true" : "false"))
        httpRequest.httpBody = requestBody.query!.data(using: .utf8)
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse .error == nil, let _ = httpResponse.data else {
            return (nil, httpResponse.error ?? "An error occured attempting to update")
        }
        return (httpResponse.data!.todo_item, nil)
    }
    
    // MARK: deleteTodoItem
    public func deleteTodoItem(todoID: UInt64, token: String) async -> String? {
        struct ResponseSchema: Decodable {
            var message: String
        }
        let endpoint = todoEndpoint + "/item/\(todoID)"
        var httpRequest = URLRequest(url: URL(string: endpoint)!)
        httpRequest.httpMethod = "DELETE"
        httpRequest.setValue(token, forHTTPHeaderField: "Authorization")
        let httpResponse = await NetworkRequest().http(httpRequest, expectedType: ResponseSchema.self)
        guard httpResponse.error == nil, let _ = httpResponse.data else {
            return httpResponse.error ?? "An error occured attempting to delete"
        }
        return nil
    }
    
}
