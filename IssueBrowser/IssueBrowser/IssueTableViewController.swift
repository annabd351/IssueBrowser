//
//  IssueTableViewController.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/10/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

// Display a list of issues

import UIKit

private let issueCellReuseID = "issueCell"
private let activityIndicatorCellReuseID = "activityIndicatorCell"
private let mainStoryboardName = "Main"
private let issueDetailViewControllerID = "IssueDetailViewController"
private let navBarTitle = "GitHub Issue Browser"

private let dateFormatter: DateFormatter = {
    let newDateFormatter = DateFormatter()
    newDateFormatter.dateStyle = .short
    return newDateFormatter
}()

class IssueTableViewController: UITableViewController {
    private var issues: [Issue] = []

    enum State {
        case loading
        case displaying
    }
    private var state = State.loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.title = navBarTitle

        // Trick to prevent empty cells from appearing during initial data load
        tableView.tableFooterView = UIView(frame: .zero)
        
        GitHub.issuesAndCommentsFor(repo: GitHub.testRepoName) {
            [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let issues):
                strongSelf.issues = issues.sorted(by: { $0.uniqueCommenters.count > $1.uniqueCommenters.count })
                DispatchQueue.main.async {
                    strongSelf.state = .displaying
                    strongSelf.tableView.reloadData()
                }
            case .failure(let error):
                strongSelf.presentAlert(title: "Network Error", message: error.localizedDescription)
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state == .loading ? 1 : issues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .loading:
            return tableView.dequeueReusableCell(withIdentifier: activityIndicatorCellReuseID, for: indexPath)
        case .displaying:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: issueCellReuseID, for: indexPath) as? IssueTableViewCell else {
                // No way to recover from this error -- we must return a cell.
                fatalError("Could not dequeue IssueTableViewCell")
            }
            
            let issue = issues[indexPath.row]
            cell.titleLabel.text = issue.title
            cell.dateLabel.text = dateFormatter.string(from: issue.created_at)
            cell.userLabel.text = issue.user.login
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let issueDetailViewController = UIStoryboard(name: mainStoryboardName, bundle: nil).instantiateViewController(withIdentifier: issueDetailViewControllerID) as? IssueDetailViewController else {
            // If this happens in a working app on a healthy system, it's probably a memory issue.
            // Could handle this slightly more gracefully by finding memory to free up.
            presentAlert(title: "Problem", message: "Could not load IssueDetailViewController")
            return
        }
        issueDetailViewController.issue = issues[indexPath.row]
        navigationController?.pushViewController(issueDetailViewController, animated: true)
    }
}
