//
//  IssueBrowserTests.swift
//  IssueBrowserTests
//
//  Created by Anna Dickinson on 9/6/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

import XCTest
@testable import IssueBrowser

import PromiseKit

class IssueBrowserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // See if we can hit the GitHub endpoint.
    func testValidAccessIssueEndpoint() {
        let testRepo = GitHub.testRepoName
        let expectation = XCTestExpectation()
        firstly { GitHub.issuesFor(repo: testRepo) }
            .done {
                result in
                print("Got \(result.count) issues")
                XCTAssert(true)
                expectation.fulfill()
            }
            .catch {
                error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    // Make sure we can catch errors for an invalid repo
    // NOTE: This is a non-deterministic test.  Check result carefully.
    func testInvalidAccessIssueEndpoint() {
        // This repo is not likely to exist, but it might...
        let testRepo = UUID().uuidString
        let expectation = XCTestExpectation()
        firstly { GitHub.issuesFor(repo: testRepo) }
            .done {
                result in
                XCTFail("Returned \(result) from invalid repo \"\(testRepo)\"")
                expectation.fulfill()
            }
            .catch {
                error in
                XCTAssert(true)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

    // Check handling of a repo with zero issues
    func testEmptyIssueList() {
        let repoWithNoIssues = "annabd351/IssueBrowser"
        let expectation = XCTestExpectation()
        firstly { GitHub.issuesFor(repo: repoWithNoIssues) }
            .done {
                result in
                XCTAssertTrue(result.isEmpty)
                expectation.fulfill()
            }
            .catch {
                error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testGetCommentsForIssue() {
        let testRepo = GitHub.testRepoName
        let expectation = XCTestExpectation()
        firstly { GitHub.issuesFor(repo: testRepo) }
            .then {
                (issues: [Issue]) -> Promise<[Comment]> in
                XCTAssertNotNil(issues.first, "No issues returned")
                print(issues.first!)
                return GitHub.commentsFor(issue: issues.first!)
            }
            .done {
                (comments: [Comment]) in
                print("Got \(comments.count) comments")
                XCTAssert(true)
                expectation.fulfill()
            }
            .catch {
                error in
                XCTFail(error.localizedDescription)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
}
