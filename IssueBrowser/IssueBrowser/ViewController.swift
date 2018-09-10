//
//  ViewController.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/6/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var issues: [Issue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        GitHub.createFor(repo: GitHub.testRepoName) {
            result in
            switch result {
            case .success(let github):
                self.issues = github.issues
//                printStuff()
            case .failure(let error):
                print(error)
            }
        }
        
        func printStuff() {
            print("Total issues: \(issues.count)")
            issues.forEach {
                print("Comment url: \($0.comments_url)")
//                print("Comments: \($0.comments.count)")
//                print("Unique comments: \($0.uniqueCommenters.count)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

