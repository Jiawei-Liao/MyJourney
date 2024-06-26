//
//  ChangeDateViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 12/4/2024.
//

import UIKit

protocol ChangeDateDelegate: AnyObject {
    func changedToDate(_ date: Date)
}

class ChangeDateViewController: UIViewController {
    
    // View controller variables
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // Change date button action
    @IBAction func changeDate(_ sender: Any) {
        delegate?.changedToDate(datePicker.date)
        navigationController?.popViewController(animated: true)
    }
    
    // Variables
    var initialDate: Date?
    weak var delegate: ChangeDateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.maximumDate = Date()
        
        if let initialDate = initialDate {
            datePicker.date = initialDate
        }
    }
}
