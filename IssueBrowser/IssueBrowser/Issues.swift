//
//  Issues.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/7/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

// Data models matching GitHub API format.

import Foundation

struct Issue: Decodable {
    let comments_url: URL
    let title: String
    let body: String
    let user: User
    let created_at: Date
    
    enum CodingKeys: String, CodingKey {
        case comments_url
        case title
        case body
        case user
        case created_at
    }
    
    // Additional values which are set separately (not part of JSON decoding)
    var comments: [Comment] = []
    var uniqueCommenters: [(user: User, count: Int)] = []
}

struct User: Decodable {
    let login: String
}

extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.login == rhs.login
    }
}

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.login < rhs.login
    }
}

extension User: Hashable {
    var hashValue: Int {
        return login.hashValue
    }
}
struct Comment: Decodable {
    let user: User
}
