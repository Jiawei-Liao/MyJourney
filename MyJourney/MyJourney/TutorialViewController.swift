//
//  TutorialViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 1/6/2024.
//

import UIKit

class TutorialViewController: UIViewController {
    // View controller variables
    
    @IBAction func skipButton(_ sender: Any) {
        segueToEntries()
    }
    @IBOutlet weak var tutorialImages: UIImageView!
    
    // Variables
    var tutorialImageNumber = 0
    let tutorialImagesName = ["Tutorial1", "Tutorial2", "Tutorial3", "Tutorial4", "Tutorial5", "Tutorial6", "Tutorial7"]
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    // Gesture recogniser action functions
    @IBAction func swipeLeftAction(_ sender: Any) {
        tutorialImageNumber += 1
        displayImage()
    }
    
    @IBAction func tapAction(_ sender: Any) {
        tutorialImageNumber += 1
        displayImage()
    }
    
    @IBAction func swipeRightAction(_ sender: Any) {
        tutorialImageNumber -= 1
        displayImage()
    }
    
    // Displays the tutorial image or segues to user's journey if complete
    func displayImage() {
        // Set index to 0 if trying to go negative
        if tutorialImageNumber < 0 {
            tutorialImageNumber = 0
        } else if tutorialImageNumber > 6 {
            // Segue to user's entries
            segueToEntries()
        } else {
            tutorialImages.image = UIImage(named: tutorialImagesName[tutorialImageNumber])
        }
    }
    
    func segueToEntries() {
        // Set tutorial done status to true
        databaseController?.setTutorialDone(status: true)
        // Get main view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myJourney = storyboard.instantiateViewController(withIdentifier: "myJourney")
        // Transition to that view controller
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = scene.windows.first {
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromBottom, animations: {
                window.rootViewController = myJourney
            }, completion: nil)
        }
    }
}
