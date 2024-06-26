//
//  AddImageViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 25/4/2024.
//

import UIKit
import CoreData

class AddImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DisplayMessageDelegate {
    // Get picked image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        
        dismiss(animated: true)
    }
    
    // Cancel picking image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    // View controller variables
    @IBOutlet weak var imageView: UIImageView!
    
    // Save image navigation bar item action
    @IBAction func saveImage(_ sender: Any) {
        guard let image = imageView.image else {
            displayMessage(title: "Error", message: "Cannot save until an image has been selected", controller: self)
            return
        }
        
        delegate?.addImage(image)
        navigationController?.popViewController(animated: true)
    }
    
    // Add image button action
    @IBAction func addImage(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        // Action sheet for different methods of importing images
        let actionSheet = UIAlertController(title: nil, message: "Select Option", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            controller.sourceType = .camera
            self.present(controller, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
        
        let albumAction = UIAlertAction(title: "Photo Album", style: .default) { action in
            controller.sourceType = .savedPhotosAlbum
            self.present(controller, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(cameraAction)
        }
        
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // Variables
    weak var delegate: AddImageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
