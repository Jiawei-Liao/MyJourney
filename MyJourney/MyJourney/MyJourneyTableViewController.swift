//
//  MyJourneyTableViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 6/4/2024.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

// Delegate method to resize table view when a group is expanded
protocol JourneyGroupExpanded {
    func groupExpanded(index: Int, value: Bool)
    func didSelectJourney(journey: Journey)
}

// Structure for storing journey lists, group expanded bool and date
struct JourneyGroup {
    var date: Timestamp
    var isExpanded: Bool
    var journeyList: [Journey]
}

class MyJourneyTableViewController: UITableViewController, DatabaseListener, JourneyGroupExpanded {
    func groupExpanded(index: Int, value: Bool) {
        // Make changes to the expanded group and reload table
        journeyGroups[index].isExpanded = value
        journeyGroupTableView.performBatchUpdates(nil)
    }
    
    func didSelectJourney(journey: Journey) {
        performSegue(withIdentifier: "viewEntrySegue", sender: journey)
    }
    
    func onJourneyChange(change: DatabaseChange, journey: [Journey]) {
        // Initialise variables
        let journeyList = journey
        journeyGroups = [JourneyGroup]()
        
        for journey in journeyList {
            // All journey should have a date
            guard let journeyDate = journey.date else {
                break
            }
            
            if let index = journeyGroups.firstIndex(where: { calendar.compare($0.date.dateValue(), to: journey.date!.dateValue(), toGranularity: .day) == .orderedSame }) {
                // Try to find if journey date is already a group
                let insertIndex = journeyGroups[index].journeyList.firstIndex { $0.date!.dateValue() < journey.date!.dateValue() } ?? journeyGroups[index].journeyList.endIndex
                journeyGroups[index].journeyList.insert(journey, at: insertIndex)
            } else {
                // Create a new group
                let newJourneyGroup = JourneyGroup(date: journey.date!, isExpanded: false, journeyList: [journey])
                // Append the new group, sorted by date
                if let insertIndex = journeyGroups.firstIndex(where: { $0.date.dateValue() < journeyDate.dateValue() }) {
                    journeyGroups.insert(newJourneyGroup, at: insertIndex)
                } else {
                    journeyGroups.append(newJourneyGroup)
                }
            }
        }
        
        journeyGroupTableView.reloadData()
    }
    
    @IBOutlet var journeyGroupTableView: UITableView!
    
    @IBAction func logout(_ sender: Any) {
        // Get login view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        // Transition to that view controller
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = scene.windows.first {
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromTop, animations: {
                window.rootViewController = loginVC
            }, completion: nil)
        }
    }
    
    // Variables
    weak var firebaseController: FirebaseProtocol?
    var journeyGroups = [JourneyGroup]()
    var listenerType: ListenerType = .journey
    let CELL_JOURNEY = "journeyCell"
    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        firebaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeyGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_JOURNEY, for: indexPath) as! JourneyTableViewCell

        cell.index = indexPath.row
        cell.journeyGroup = journeyGroups[indexPath.row]
        cell.delegate = self
        
        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewEntrySegue" {
            let destination = segue.destination as! ViewEntryViewController
            let journey = sender as! Journey
            destination.journey = journey
        }
    }
}
