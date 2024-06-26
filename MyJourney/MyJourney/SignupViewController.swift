//
//  SignupViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 6/4/2024.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate, DisplayMessageDelegate {
    
    // Dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // View controller variables
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordIcon: UIButton!
    
    @IBAction func passwordToggle(_ sender: Any) {
        passwordTextField.isSecureTextEntry.toggle()
        let iconName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        passwordIcon.setImage(UIImage(systemName: iconName), for: .normal)
    }
    
    @IBAction func signup(_ sender: Any) {
        // Check email
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
                displayMessage(title: "Invalid password or username", message: "Please provide a valid email or password", controller: self)
                return
            }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            displayMessage(title: "Invalid email", message: "Please provide a valid email address", controller: self)
            return
        }
        
        // Use firebase to signup
        Task {
            let success = await firebaseController?.signup(email: email, password: password)
            if success != "" {
                displayMessage(title: "Failed to signup", message: success ?? "Failed to signup", controller: self)
                return
            }
            
            // Store email in core data
            databaseController?.setLogin(email: emailTextField.text!)
            
            // Get main view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var nextVC = storyboard.instantiateViewController(withIdentifier: "tutorial")
            if tutorialDone {
                nextVC = storyboard.instantiateViewController(withIdentifier: "myJourney")
            }
            // Transition to that view controller
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = scene.windows.first {
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromBottom, animations: {
                    window.rootViewController = nextVC
                }, completion: nil)
            }
        }
    }
    
    @IBAction func displayLogin(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signupVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = scene.windows.first {
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = signupVC
            }, completion: nil)
        }
    }
    
    // Variables
    weak var databaseController: DatabaseProtocol?
    weak var firebaseController: FirebaseProtocol?
    var tutorialDone: Bool = false
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        firebaseController = appDelegate?.firebaseController
        
        if let tutorial = databaseController?.getTutorialDone() {
            tutorialDone = tutorial.tutorialDone
        }
        
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}
