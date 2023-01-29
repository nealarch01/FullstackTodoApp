//
//  Todo.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import Foundation

struct Todo: Codable, Identifiable {
    var id: UInt64
    var title: String
    var description: String?
    var creatorID: Int
    var createdAt: String
    var dueAt: String?
    var completed: Bool
    var listID: UInt64?
    var priority: Int
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case creatorID = "creator_id"
        case description = "description"
        case createdAt = "created_at"
        case dueAt = "due_at"
        case completed = "completed"
        case listID = "list_id"
        case priority = "priority"
    }
    
    init(id: UInt64 = 1) {
        self.id = id
        title = "Learn PostgreSQL"
        description = "Learn how to use SQL"
        creatorID = 0
        createdAt = ""
        dueAt = nil
        completed = false
        listID = nil
        priority = 0
    }
}
