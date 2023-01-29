//
//  TodoList.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import Foundation

struct TodoList: Codable, Identifiable {
    var id: UInt64
    var creatorID: UInt64
    var name: String
    var createdAt: String
    var color: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case creatorID = "creator_id"
        case name = "name"
        case createdAt = "created_at"
        case color = "color"
    }
    
    // Test init
    init(id: UInt64 = 1) {
        self.id = id
        creatorID = 1
        name = "Test"
        createdAt = "Today"
        color = "#00ff00"
    }
}
