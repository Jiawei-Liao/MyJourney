//
//  DisplayMessageDelegate.swift
//  MyJourney
//
//  Created by Jiawei Liao on 1/6/2024.
//

import Foundation
import UIKit

protocol DisplayMessageDelegate: AnyObject {
    func displayMessage(title: String, message: String, controller: UIViewController)
}

extension DisplayMessageDelegate {
    func displayMessage(title: String, message: String, controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
}
