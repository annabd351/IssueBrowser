//
//  IssueDetailViewController.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/10/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

import UIKit

class IssueDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var commentersLabel: UILabel!
    
    var issue: Issue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let issue = issue else {
            // Programmer error
            fatalError("issue not set")
        }
        
        titleLabel.text = issue.title
        authorLabel.text = issue.user.login
        bodyLabel.text = issue.body

        let sortedCommenters = issue.uniqueCommenters.sorted {
            if $0.count == $1.count {
                return $0.user < $1.user
            }
            else {
                return $0.count > $1.count
            }
        }
        
        let commenterStrings = sortedCommenters.map { "\($0.user.login) (\($0.count))" }.joined(separator: ", ")
        commentersLabel.text = commenterStrings
    }
}
