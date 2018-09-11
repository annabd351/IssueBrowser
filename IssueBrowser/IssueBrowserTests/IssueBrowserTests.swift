//
//  IssueBrowserTests.swift
//  IssueBrowserTests
//
//  Created by Anna Dickinson on 9/6/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

import XCTest
import Alamofire

@testable import IssueBrowser

class IssueBrowserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // See if we can hit the GitHub endpoint and decode a response.
    func testGitHubIssuesFor() {
        // Uncomment to test the test itself -- should fail (unless the string is a valid repo)
        // let testRepo = "jknasdfhhu81378fgh934hrfiasdhfjkhajkshd91398h4gh3rg"
        let testRepo = GitHub.testRepoName
        let expectation = XCTestExpectation()
        GitHub.issuesFor(repo: testRepo) {
            result in
            switch result {
            case .success:
                XCTAssert(true)
                expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    // Try fetching comments for an issue
    func testGitHubCommentsFor() {
        // Some test-the-test cases
        // let testRepo = "jknasdfhhu81378fgh934hrfiasdhfjkhajkshd91398h4gh3rg"
        // let testRepo = "annabd351/IssueBrowser"
        let testRepo = GitHub.testRepoName
        let expectation = XCTestExpectation()
        GitHub.issuesFor(repo: testRepo) {
            result in
            switch result {
            case .success(let value) where value.isEmpty:
                XCTFail("No issues for \(testRepo)")
                expectation.fulfill()
            case .success(let value):
                handleComments(issue: value.first!)
            case .failure(let error):
                XCTFail(error.localizedDescription)
                expectation.fulfill()
            }
        }

        func handleComments(issue: Issue) {
            GitHub.commentsFor(issue: issue) {
                result in
                switch result {
                case .success:
                    XCTAssert(true)
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 10)
    }
}
