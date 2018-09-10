//
//  GitHub.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/7/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

import Foundation
import Alamofire

private let username = "annabd351"
private let password = "=NwLZiKwh7PPvospntMi&ws2ptvQaVBA"
private let credentialData = "\(username):\(password)".data(using: .utf8)!.base64EncodedData()

// Create an Alamofire SessionManager for use with GitHub.  Configure default headers.
private let sessionManager: SessionManager = {
    var configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = ["Accept" : "application/vnd.github.v3+json"]
    let headers = ["Authorization": "Basic \(credentialData)"]
    return Alamofire.SessionManager(configuration: configuration)
}()

// Queues for GitHub network interactions
private let concurrentQueue = DispatchQueue(label: "GitHubConcurrentQueue" + UUID().uuidString, attributes: .concurrent)
private let serialQueue = DispatchQueue(label: "GitHubSerialQueue" + UUID().uuidString)

// Used for all JSON decoding
private let decoder: JSONDecoder = {
    let newDecoder = JSONDecoder()
    newDecoder.dateDecodingStrategy = .iso8601
    return newDecoder
}()

private let baseURL = URL(string: "https://api.github.com")!

// Abstraction of the GitHub API itself
class GitHub {
    var issues: [Issue] = []
    
    static let testRepoName = "grpc/grpc-swift"
//    static let testRepoName = "annabd351/IssueBrowser"

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
    // TODO: Create generic function to process response and/or function conforming to Alamofire.DataResponseSerializer
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
    // TODO: Create generic function to process response and/or function conforming to Alamofire.DataResponseSerializer
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
    
    // Return unique users from an array of Comments
    static func uniqueCommentersFor(comments: [Comment]) -> Set<User> {
        let allUsers = comments.map { $0.user }
        return Set<User>(allUsers)
    }

    // Create an instance of GitHub and fill it with all data
    static func createFor(repo: String, completion: @escaping (Result<GitHub>) -> ()) {
        let instance = GitHub()
        
        issuesFor(repo: repo) {
            result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let issues):
                instance.issues = issues
                
                let commentFetchGroup = DispatchGroup()
                
                for index in 0..<instance.issues.count {
                    print("Getting issue \(index)")
                    
                    // Fetch all the comments serially
                    // TODO: Fetch the comments concurrently
                    commentFetchGroup.enter()
                    commentsFor(issue: instance.issues[index]) {
                        result in
                        switch result {
                        case .failure(let error):
                            completion(.failure(error))
                        case .success(let comments):
                            instance.issues[index].comments = comments
                            instance.issues[index].uniqueCommenters = uniqueCommentersFor(comments: comments)
                        }
                        commentFetchGroup.leave()
                    }
                }
                commentFetchGroup.notify(queue: serialQueue) {
                    completion(.success(instance))
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


