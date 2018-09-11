//
//  GitHub.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/7/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

// Functionality for accessing the GitHub API

import Foundation
import Alamofire

// Enter appropriate values:  GitHub rate limits the API if you don't authenticate.
private let username = "<<YOUR USERNAME>>"
private let password = "<<YOUR PASSWORD>>"
private let credentialData = "\(username):\(password)".data(using: .utf8)!.base64EncodedData()

// Create an Alamofire SessionManager for use with GitHub.  Configure default headers.
private let sessionManager: SessionManager = {
    var configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = ["Accept" : "application/vnd.github.v3+json"]
    let headers = ["Authorization": "Basic \(credentialData)"]
    return Alamofire.SessionManager(configuration: configuration)
}()

// Used for all JSON decoding
private let decoder: JSONDecoder = {
    let newDecoder = JSONDecoder()
    newDecoder.dateDecodingStrategy = .iso8601
    return newDecoder
}()

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
    
    // Get all issues for a repo.
    static func issuesFor(repo: String, completion: @escaping (Result<[Issue]>) -> ()) {
        sessionManager.request(Endpoint.issues(repo: repo)).responseData {
            response in
            switch response.result {
            case .success(let value):
                do {
                    let issues = try decoder.decode([Issue].self, from: value)
                    completion(.success(issues))
                }
                catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get the comments for one issue.
    static func commentsFor(issue: Issue, completion: @escaping (Result<[Comment]>) -> ()) {
        sessionManager.request(issue.comments_url).responseData {
            response in
            switch response.result {
            case .success(let value):
                do {
                    let comments = try decoder.decode([Comment].self, from: value)
                    completion(.success(comments))
                }
                catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Return unique users and comment count
    private static func uniqueCommentersFor(comments: [Comment]) -> [(User, Int)] {
        let countedSet = NSCountedSet(array: comments.map { $0.user })
        return countedSet.allObjects.map { (($0 as! User), countedSet.count(for: $0)) }
    }

    // Fetch the issues and all associated comments for a repo
    static func issuesAndCommentsFor(repo: String, completion: @escaping (Result<[Issue]>) -> ()) {
        issuesFor(repo: repo) {
            result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(var issues):
                let commentFetchQueue = DispatchQueue(label: "commentFetch.Queue.GitHub.IssueBrowser" + UUID().uuidString, attributes: .concurrent)
                let commentFetchGroup = DispatchGroup()
                
                // Fetch all the comments
                for index in 0..<issues.count {
                    commentFetchGroup.enter()
                    commentsFor(issue: issues[index]) {
                        result in
                        switch result {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success(let comments):
                            issues[index].comments = comments
                            issues[index].uniqueCommenters = uniqueCommentersFor(comments: comments)
                        }
                        commentFetchGroup.leave()
                    }
                }
                commentFetchGroup.notify(queue: commentFetchQueue) {
                    completion(.success(issues))
                }
            }
        }
    }
}

extension GitHub.Endpoint: Alamofire.URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        return URLRequest(url: self.url)
    }
}
