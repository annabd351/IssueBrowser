//
//  ViewController.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/6/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

import UIKit
import PromiseKit

class ViewController: UIViewController {

    var issues: [Issue] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        firstly {
//            GitHub.issuesFor(repo: GitHub.testRepoName)
//            }
//            .done {
//                result in
//                print(result)
//            }
//            .catch {
//                error in
//                print(error)
//        }
        
        firstly {
            return GitHub.issuesFor(repo: GitHub.testRepoName)
            }.done {
                issues in
                self.issues = issues
            }.catch {
                error in
                print(error.localizedDescription)
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

