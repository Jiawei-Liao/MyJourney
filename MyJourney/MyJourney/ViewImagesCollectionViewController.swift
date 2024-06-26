//
//  ViewImagesCollectionViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 25/4/2024.
//

import UIKit

protocol AddImageDataDelegate: AnyObject {
    func addImageData(_ data: [Data])
}

class ViewImagesCollectionViewController: UICollectionViewController, AddImageDelegate {
    // Adds image after picking
    func addImage(_ image: UIImage) {
        imageList.append(image)
        collectionView.reloadData()
    }
    
    // Go to add image view controller navigation bar item action
    @IBAction func goToAddImage(_ sender: Any) {
        performSegue(withIdentifier: "addImageSegue", sender: sender)
    }
    
    // Variables
    let CELL_IMAGE = "imageCell"
    var imageList = [UIImage]()
    var imageDataList = [Data]()
    weak var delegate: AddImageDataDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Convert data to images
        for imageData in imageDataList {
            if let image = UIImage(data: imageData) {
                imageList.append(image)
            } else {
                print("Failed to create UIImage from data")
            }
        }
        
        // Generate layout
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Initialise list of image data
        imageDataList = [Data]()
        
        // Initialise renderer to shrink images
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 128, height: 128))
        
        // Shrink image and convert to data
        for image in imageList {
            let imageData = renderer.jpegData(withCompressionQuality: 0.5) { (context) in
                image.draw(in: CGRect(origin: .zero, size: CGSize(width: 128, height: 128)))
            }
            imageDataList.append(imageData)
        }
        
        delegate?.addImageData(imageDataList)
        super.viewWillDisappear(animated)
    }

    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "addImageSegue" {
             let destination = segue.destination as! AddImageViewController
             destination.delegate = self
         }
     }

    // MARK: UICollectionViewDataSource
    
    func generateLayout() -> UICollectionViewLayout {
        let imageItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let imageItem = NSCollectionLayoutItem(layoutSize: imageItemSize)
        imageItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let imageGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3))
        
        let imageGroup = NSCollectionLayoutGroup.horizontal(layoutSize: imageGroupSize, subitems: [imageItem])
        let imageSection = NSCollectionLayoutSection(group: imageGroup)
        
        return UICollectionViewCompositionalLayout(section: imageSection)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IMAGE, for: indexPath) as! ImageCollectionViewCell
        
        cell.backgroundColor = .secondarySystemFill
        cell.imageView.image = imageList[indexPath.row]
    
        return cell
    }
}
