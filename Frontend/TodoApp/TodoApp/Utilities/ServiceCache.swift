//
//  ServiceCache.swift
//  TodoApp
//
//  Created by Neal Archival on 1/12/23.
//


import Foundation

//func cacheNetworkResponses() {
//    // Create a shared URLCache
//    let urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
//    URLCache.shared = urlCache
//
//    // Create a URLRequest
//    let url = URL(string: "https://example.com/api/data")!
//    var request = URLRequest(url: url)
//
//    // Set the cache policy to use the cache if possible
//    request.cachePolicy = .returnCacheDataElseLoad
//
//    // Create a URLSession
//    let session = URLSession(configuration: .default)
//
//    // Create a data task
//    let task = session.dataTask(with: request) { data, response, error in
//        if let error = error {
//            print("Error: \(error)")
//        } else if let data = data, let response = response {
//            print("Data: \(data)")
//            print("Response: \(response)")
//        }
//    }
//}

