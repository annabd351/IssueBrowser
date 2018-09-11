//
//  UIViewController+Alerts.swift
//  IssueBrowser
//
//  Created by Anna Dickinson on 9/10/18.
//  Copyright © 2018 Anna Dickinson. All rights reserved.
//

// Convenience function for alert dialogs

import UIKit

extension UIViewController {
    // First action in optional list is preferred.
    func presentAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions?.forEach { alertController.addAction($0) }
        alertController.preferredAction = actions?.first
        DispatchQueue.main.async {
            [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.present(alertController, animated: true, completion: nil)
        }
    }
}
