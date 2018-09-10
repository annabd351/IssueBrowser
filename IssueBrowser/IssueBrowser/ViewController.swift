//
//  ViewController.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/6/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var gitHub: GitHub!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        GitHub.createFor(repo: GitHub.testRepoName) {
            result in
            switch result {
            case .success(let gitHub):
                self.gitHub = gitHub
                printStuff()
            case .failure(let error):
                print(error)
            }
        }
        
        func printStuff() {
            print("Total issues: \(gitHub.issues.count)")
            gitHub.issues.forEach {
                print("Comments: \($0.comments.count)")
                print("Unique comments: \($0.uniqueCommenters.count)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

