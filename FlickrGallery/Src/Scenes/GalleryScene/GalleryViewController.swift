//
//  GalleryViewController.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 01/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  var operationQueue: OperationQueue!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 3
    let session = URLSession(configuration: .default)
    
    for _ in 0..<6{
      let op = ImageDownloadOperation(flickrModel: FlickrModel(), session: session, completionHandler: nil)
      operationQueue.addOperation(op)
    }
    
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
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    print("Cell at index:\(indexPath.row)")
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: indexPath) as! FlickrCell
    cell.backgroundColor = UIColor.black
    cell.imageView.image = UIImage(named: "IMG_\(indexPath.row).jpg")
    cell.numberLabel.text = "\(indexPath.row)"
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



// MARK:- UICollectionViewDataSourcePrefetching
extension GalleryViewController: UICollectionViewDataSourcePrefetching {
  /// - Tag: Prefetching
  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//    print("Prefetch:\(indexPaths)")
    // Begin asynchronously fetching data for the requested index paths.
//    for indexPath in indexPaths {
//      let model = models[indexPath.row]
//      asyncFetcher.fetchAsync(model.id)
//    }
  }
  
  /// - Tag: CancelPrefetching
  func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    // Cancel any in-flight requests for data for the specified index paths.
//    for indexPath in indexPaths {
//      let model = models[indexPath.row]
//      asyncFetcher.cancelFetch(model.id)
//    }
  }
}

// MARK:- UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Operation:\(operationQueue.operations.count)")
  }
}

