//
//  APIError.swift
//  TodoApp
//
//  Created by Neal Archival on 1/7/23.
//

import Foundation

struct APIError: Decodable {
    var message: String
}

struct AuthError: Decodable {
    var message: String
    var invalidFields: [String]?
}
