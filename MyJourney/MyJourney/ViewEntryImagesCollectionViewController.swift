//
//  ViewEntryImagesCollectionViewController.swift
//  MyJourney
//
//  Created by Jiawei Liao on 28/4/2024.
//

import UIKit

class ViewEntryImagesCollectionViewController: UICollectionViewController {
    
    // Variables
    let CELL_IMAGE = "imageCell"
    var imageDataList = [Data]()
    var imageList = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Converting image data to UIImages
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
