//
//  JourneyTableViewCell.swift
//  MyJourney
//
//  Created by Jiawei Liao on 28/4/2024.
//

import UIKit

class JourneyTableViewCell: UITableViewCell, UITableViewDelegate {

    // Table view cell variables
    @IBOutlet weak var verticalLine: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var stackView: UIStackView! {
        // Set border around each date block
        didSet {
            stackView.layer.cornerRadius = 8
            stackView.layer.borderWidth = 1
            stackView.layer.borderColor = UIColor.label.cgColor
        }
    }
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var innerJourneyTableView: UITableView!
    @IBOutlet weak var paddingView: UIView!
    
    // Variables
    weak var firebaseController: FirebaseProtocol?
    var dateFormatter = DateFormatter()
    var index = Int()
    var delegate: JourneyGroupExpanded?
    var journeyGroup: JourneyGroup? = nil {
        // Set up the inner table view based on given journey group
        didSet {
            if let _journeyGroup = journeyGroup {
                innerJourneyTableView.isHidden = !_journeyGroup.isExpanded
                date.text = dateFormatter.string(from: _journeyGroup.date.dateValue())
                verticalLine.isHidden = _journeyGroup.isExpanded ? false : true
                innerJourneyTableView.dataSource = self
                self.stackView.setNeedsLayout()
                innerJourneyTableView.reloadData()
            }
        }
    }
    
    override func awakeFromNib() {
        // Firebase controller to allow deletion of entries
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController
        
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        self.innerJourneyTableView.allowsSelection = true
        self.innerJourneyTableView.delegate = self
        
        addTapEvent()
        
        super.awakeFromNib()
    }
    
    // Tap event for opening and closing date block entries
    func addTapEvent() {
        let panGesture = UITapGestureRecognizer(target: self, action: #selector(handleActon))
        headerView.addGestureRecognizer(panGesture)
    }
    
    // Function for the tap event for opening and closing date block entries
    @objc private func handleActon() {
        guard let isExpanded = journeyGroup?.isExpanded else {
            print("isExpanded variable not initialized")
            return
        }
        innerJourneyTableView.isHidden = isExpanded
        paddingView.isHidden = isExpanded
        verticalLine.isHidden = isExpanded
        UIView.animate(withDuration: 0.3) {
            self.stackView.setNeedsLayout()
            self.delegate?.groupExpanded(index: self.index, value: !isExpanded)
        }
        journeyGroup?.isExpanded = !isExpanded
    }
}

// Data source extension
extension JourneyTableViewCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeyGroup?.journeyList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "individualJourneyCell", for: indexPath) as? IndividualJourneyTableViewCell else {
            return UITableViewCell()
        }
        cell.journey = journeyGroup?.journeyList[indexPath.row]
        // Display the connection line if there is a next entry
        if let count = journeyGroup?.journeyList.count {
            cell.nextViewVerticalLine.isHidden = count - 1 == indexPath.row ? true : false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Delete entry
        if editingStyle == .delete {
            guard let journeyGroup = journeyGroup else {
                print("journeyGroup not initialized")
                return
            }
            
            let deletedJourney = journeyGroup.journeyList[indexPath.row]
            firebaseController?.deleteJourney(journey: deletedJourney)
        }
    }
    
    // Segue to see entry
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedJourney = journeyGroup?.journeyList[indexPath.row] else {
                print("No journey selected")
                return
            }
            
        delegate?.didSelectJourney(journey: selectedJourney)
    }
    
    // Calculate cell size and update layout
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.invalidateIntrinsicContentSize()
        tableView.layoutIfNeeded()
    }
}
