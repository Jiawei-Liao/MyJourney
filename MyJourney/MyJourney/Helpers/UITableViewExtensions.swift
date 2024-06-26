//
//  UITableViewExtensions.swift
//  MyJourney
//
//  Created by Jiawei Liao on 21/5/2024.
//

import Foundation
import UIKit

// Some extensions required for tableview in tableview
extension UITableView {
    
    public override var intrinsicContentSize: CGSize {
        // Make layout up to date and return content size
        layoutIfNeeded()
        return contentSize
    }
    
    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}
