//
//  Keychain.swift
//  TodoApp
//
//  Created by Neal Archival on 1/12/23.
//

import Foundation
import Security

func saveJWT(token: String) {
    let keychainQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "jwt",
        kSecValueData as String: token.data(using: .utf8)!,
    ]
    SecItemAdd(keychainQuery as CFDictionary, nil)
}

func getJWT() -> String? {
    let keychainQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "jwt",
        kSecReturnData as String: true,
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(keychainQuery as CFDictionary, &item)
    guard status == errSecSuccess else {
        return nil
    }
    guard let existingItem = item as? Data,
        let token = String(data: existingItem, encoding: .utf8) else {
            return nil
    }
    return token
}

