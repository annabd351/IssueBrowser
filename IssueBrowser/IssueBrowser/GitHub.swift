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
//private let concurrentQueue = DispatchQueue(label: "GitHubConcurrentQueue" + UUID().uuidString, attributes: .concurrent)
private let serialQueue = DispatchQueue(label: "GitHubSerialQueue" + UUID().uuidString)

// Used for all JSON decoding
private let decoder: JSONDecoder = {
    let newDecoder = JSONDecoder()
    newDecoder.dateDecodingStrategy = .iso8601
    return newDecoder
}()

private let baseURL = URL(string: "https://api.github.com")!

// Abstraction of the GitHub API itself
struct GitHub {
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
//        static func issuesFor(repo: String, queue: DispatchQueue = concurrentQueue, completion: @escaping (Result<[Issue]>) -> ()) {
        sessionManager.request(Endpoint.issues(repo: repo)).responseString {
            response in
            print(Endpoint.issues(repo: repo).url)
            print(response)
//            switch response.result {
//            case .success(let value):
//                do {
//                    let issues = try decoder.decode([Issue].self, from: value)
//                    completion(.success(issues))
//                }
//                catch {
//                    completion(.failure(error))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
        }
    }
    
    // Get the comments for one issue.
    // TODO: Create generic function to process response and/or function conforming to Alamofire.DataResponseSerializer
    static func commentsFor(issue: Issue, completion: @escaping (Result<[Comment]>) -> ()) {
//        static func commentsFor(issue: Issue, queue: DispatchQueue = concurrentQueue, completion: @escaping (Result<[Comment]>) -> ()) {
        sessionManager.request(issue.comments_url).responseData(queue: serialQueue) {
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
        var instance = GitHub()
        
        func getAllIssues() {
            issuesFor(repo: repo) {
//                issuesFor(repo: repo, queue: serialQueue) {
                result in
                switch result {
                case .success(let issues):
                    instance.issues = issues
                    getAllComments()
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        func getAllComments() {
            for index in 0..<instance.issues.count {
                // Fetch all the comments serially
                // TODO: Fetch the comments concurrently
                commentsFor(issue: instance.issues[index]) {
//                    commentsFor(issue: instance.issues[index], queue: serialQueue) {
                    result in
                    switch result {
                    case .success(let comments):
                        print(comments)
                        instance.issues[index].comments = comments
                        instance.issues[index].uniqueCommenters = uniqueCommentersFor(comments: comments)
                    case .failure(let error):
                        assert(false)
                        completion(.failure(error))
                    }
                }

                serialQueue.async {
                    // This executes after all the comments have been fetched.
                    completion(.success(instance))
                }
            }
        }
        
        // Start the process
        
        getAllIssues()
    }
}

extension GitHub.Endpoint: Alamofire.URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        return URLRequest(url: self.url)
    }
}


