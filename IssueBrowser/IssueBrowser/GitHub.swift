//
//  GitHub.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/7/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

private let baseURL = URL(string: "https://api.github.com")!

// Abstraction of the GitHub API itself
struct GitHub {
    static let testRepoName = "grpc/grpc-swift"
    
    // Endpoints we can access
    fileprivate enum Endpoint {
        case issues(repo: String)
        
        var url: URL {
            switch self {
            case .issues(let repo):
                return baseURL
                    .appendingPathComponent("repos")
                    .appendingPathComponent(repo)
                    .appendingPathComponent("issues")
            }
        }
    }
    
    static func issuesFor(repo: String) -> Promise<[Issue]> {
        return sessionManager.request(GitHub.Endpoint.issues(repo: repo)).responseDecodable([Issue].self, decoder: decoder)
    }
    
    static func commentsFor(issue: Issue) -> Promise<[Comment]> {
        return sessionManager.request(issue.comments_url).responseDecodable([Comment].self, decoder: decoder)
    }
}

extension GitHub.Endpoint: Alamofire.URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        return URLRequest(url: self.url)
    }
}

// Create an Alamofire SessionManager for use with GitHub.  Configure default headers.
private let sessionManager: SessionManager = {
    var configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = ["Accept" : "application/vnd.github.v3+json"]
    return Alamofire.SessionManager(configuration: configuration)
}()

private let decoder: JSONDecoder = {
    let newDecoder = JSONDecoder()
    newDecoder.dateDecodingStrategy = .iso8601
    return newDecoder
}()

