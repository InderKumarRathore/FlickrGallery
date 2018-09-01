//
//  GalleryViewController.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 01/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

// MARK:- UISearchBarDelegate
extension GalleryViewController: UISearchBarDelegate {
  // Search tapped on keyboard
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  // Cancel tapped
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}


// MARK:- UICollectionViewDataSource
extension GalleryViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 100
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell",
                                                  for: indexPath)
    cell.backgroundColor = UIColor.black
    // Configure the cell
    return cell
  }
}


// MARK:- UICollectionViewDelegateFlowLayout
extension GalleryViewController: UICollectionViewDelegateFlowLayout {
  // Set the size of the cell
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      // Number of cells that we want to be displayed in single row
      let cellsPerRow: CGFloat = 3.0
      // Calculate the empty/padding space needed between the cells (left to right)
      let paddingSpace = collectionViewFlowLayout.sectionInset.left * (cellsPerRow + 1)
      // Calculate the avaialble width for cells
      let availableWidthForAllCells = collectionView.frame.width - paddingSpace
      // Width per cell
      var widthPerCell = (availableWidthForAllCells / cellsPerRow)
      // Round the value downward
      widthPerCell.round(.down)
      return CGSize(width: widthPerCell, height: widthPerCell)
    }
    else {
      print("Warning: Layout is not flow layout")
      return CGSize(width: 100.0, height: 100.0)
    }
  }
}


