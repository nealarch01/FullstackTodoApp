//
//  RegexTester.swift
//  TodoApp
//
//  Created by Neal Archival on 1/10/23.
//

import Foundation

class RegexTester {
    public func verifyUsername(_ username: String) -> Bool {
        // This regular expression matches a string that:
        // 1. Contains only alphanumeric characters, underscores, dashes, and periods
        // 2. Every period, dash, and underscore is preceded and followed by an alphanumeric character
        // 3. Must contain at least one letter (to prevent usernames like "1234567890")
        // 4. Must be at least 3 characters
        if username.count < 3 {
            return false
        }
        let pattern = #"^(?=.*[A-Za-z])[A-Za-z0-9]*(?:[._-][A-Za-z0-9]+)*$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            print("Failed to initialize username regular expression. Returning false.")
            return false
        }
        let matches = regex.matches(in: username, range: NSRange(username.startIndex..., in: username))
        return !matches.isEmpty
    }

    public func verifyEmail(_ email: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            print("Failed to initialize email regular expression. Returning false.")
            return false
        }
        let matches = regex.matches(in: email, range: NSRange(email.startIndex..., in: email))
        return !matches.isEmpty
    }

    public func verifyPassword(_ password: String) -> Bool {
        // This regular expression matches a string that:
        // 1. contain at least one lowercase letter (?=.*[a-z])
        // 2. contain at least one uppercase letter (?=.*[A-Z])
        // 3. contain at least one digit (?=.*[0-9])
        // 4. contain at least one special character (?=.*[!@#\$%\^&\*])
        if password.count < 8 {
            return false
        }
        let pattern = #"^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%\^&\*])"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            print("Failed to initialize password regular expression. Returning false.")
            return false
        }
        let matches = regex.matches(in: password, range: NSRange(password.startIndex..., in: password))
        return !matches.isEmpty
    }
}
