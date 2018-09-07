//
//  Issues.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/7/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

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
    
    // Additional values which don't come from the API directly
    var comments: [Comment] = []
    var uniqueCommenters: Set<User> = []
}

//struct IssueWithComments {
//    let issue: Issue
//
//    // NOTE: Array copy is happening here...
//    init(issue: Issue, comments: [Comment]) {
//        self.issue = issue
//        self.comments = comments
//        self.uniqueCommenters = Set<User>(comments.map { $0.user })
//    }
//}

struct User: Decodable {
    let login: String
}

extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.login == rhs.login
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
