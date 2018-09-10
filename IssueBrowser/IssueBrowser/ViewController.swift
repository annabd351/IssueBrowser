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

        var gitHub: GitHub?
        GitHub.createFor(repo: GitHub.testRepoName) {
            result in
            switch result {
            case .success(let github):
                gitHub = github
            case .failure(let error):
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

