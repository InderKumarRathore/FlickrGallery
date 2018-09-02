//
//  GalleryViewController.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 01/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import UIKit


// Class only protocol, b'coz GalleryVC needs to be weak in presenter
protocol GalleryDisplayLogic: class {
  
  /// Displays the flickr objects of new search
  ///
  /// - Parameters:
  ///   - isNewSearch: whether the search was new or exisiting
  ///   - flickrArray: list of `FlickrModel`
  ///   - canLoadMore: Wether it can load more data or not
  func displayFetchedObjects(isNewSearch: Bool, flickrArray: [FlickrModel], canLoadMore: Bool)
  
  /// Shows the loader
  func showLoader()
  
  /// Hides the loader
  func hideLoader()
  
  /// Shows the error message
  ///
  /// - Parameter _msg: Message to be displayed
  func showError(_ msg: String)
}

class GalleryViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // Holds the array fo models
  private var flickrArray = [FlickrModel]()
  
  
  /// Indicates that more data can be loaded
  private var canLoadMore = false
  
  // Clean Architecture references
  var interactor: GalleryBusinessLogic!
  
  /// Image fetcher to fetch the images asyncronously
  let imageFetcher = ImageFetcher(concurrentOperations: 3, cacheImageCount: 50)
  
  // MARK: Object lifecycle
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setUpCleanArchitecture()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUpCleanArchitecture()
  }
  
  /// Set ups the clean architecture
  /// You can read more about it at the below link
  /// https://hackernoon.com/introducing-clean-swift-architecture-vip-770a639ad7bf
  private func setUpCleanArchitecture() {
    let viewController = self
    let interactor = GalleryInteractor()
    let presenter = GalleryPresenter()
    viewController.interactor = interactor // strong reference
    interactor.presenter = presenter // strong reference
    presenter.viewController = viewController // weak reference
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Clear the image cache
    self.imageFetcher.clearCache()
  }
  
  /// Gets the size for the cell
  ///
  /// - Parameter collectionView: collection view
  /// - Returns: size for the cells
  func getSizeOfCell(collectionView: UICollectionView) -> CGSize {
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
      ////print("Warning: Layout is not flow layout")
      return CGSize(width: 100.0, height: 100.0)
    }
  }
  
  func loadMore() {
    self.interactor.fetchPage(isNewSearch: false, text: nil)
  }
  
  
}

// MARK:- GalleryDisplayLogic
extension GalleryViewController: GalleryDisplayLogic {
  func displayFetchedObjects(isNewSearch: Bool, flickrArray: [FlickrModel], canLoadMore: Bool) {
    if isNewSearch {
      self.flickrArray = flickrArray
      self.collectionView.reloadData()
    }
    else {
      var indexPaths = [IndexPath]()
      let count = self.flickrArray.count
      for i in 0..<flickrArray.count {
        let indexPath = IndexPath(row: count + i, section: 0)
        indexPaths.append(indexPath)
      }
      self.flickrArray.append(contentsOf: flickrArray)
      self.collectionView.insertItems(at: indexPaths)
    }
    self.canLoadMore = canLoadMore
  }
  
  func showLoader() {
    self.activityIndicator.startAnimating()
  }
  
  func hideLoader() {
    self.activityIndicator.stopAnimating()
  }
  
  func showError(_ msg: String) {
    let alert = UIAlertController(title: "Oppsss!", message: msg, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    self.present(alert, animated: true, completion: nil)
  }
}


// MARK:- UISearchBarDelegate
extension GalleryViewController: UISearchBarDelegate {
  // Search tapped on keyboard
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    if searchBar.text != "" {
      // Empty the array & collection view
      self.flickrArray.removeAll()
      self.collectionView.reloadData()
      self.canLoadMore = false
      // Tell the interactor that view need new data
      self.interactor.fetchPage(isNewSearch: true, text: searchBar.text!)
    }
  }
  
  // Cancel tapped
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}

// MARK:- UICollectionViewDataSource
extension GalleryViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.flickrArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //    ////print("Cell at index:\(indexPath.row)")
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCell", for: indexPath) as! FlickrCell
    // Set the tag to compare in the completion handler
    cell.tag = indexPath.row
    
    let flickrModel = self.flickrArray[indexPath.row]
    let width = Int(getSizeOfCell(collectionView: collectionView).width * UIScreen.main.scale)
    //print("Cell for row: \(indexPath.row)")
    self.imageFetcher.getImageFor(flickrModel: flickrModel, width: width, priority: .high, index: indexPath.row) { (image) in
      DispatchQueue.main.async {
        ////print("Data fetched: \(indexPath.row)")
        //Check if the cell is the same cell that requested this image
        if cell.tag == indexPath.row {
          cell.imageView.image = image
        }
      }
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterID", for: indexPath)
    return footerView
  }
}


// MARK:- UICollectionViewDelegateFlowLayout
extension GalleryViewController: UICollectionViewDelegateFlowLayout {
  // Set the size of the cell
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return getSizeOfCell(collectionView: collectionView)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    if self.canLoadMore {
      return CGSize(width: collectionView.frame.size.width, height: 40)
    }
    else {
      return CGSize.zero
    }
  }
}


// MARK:- UICollectionViewDataSourcePrefetching
extension GalleryViewController: UICollectionViewDataSourcePrefetching {
  /// Prefetch data
  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    // Begin asynchronously fetching data for the requested index paths.
    for indexPath in indexPaths {
      ////print("Prefetching: \(indexPath.row)")
      let flickrModel = flickrArray[indexPath.row]
      let width = Int(getSizeOfCell(collectionView: collectionView).width * UIScreen.main.scale)
      self.imageFetcher.getImageFor(flickrModel: flickrModel, width: width, priority: .low, index: indexPath.row, completionHandler: nil)
    }
  }
  
  /// Cancel prefetching
  func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    // Cancel any in progress requests for data for the specified index paths.
    for indexPath in indexPaths {
      ////print("Cancel prefetch: \(indexPath.row)")
      if flickrArray.count > indexPath.row {
        let flickrModel = flickrArray[indexPath.row]
        self.imageFetcher.cancelImageLoadingFor(flickrModel: flickrModel)
      }
    }
  }
}

// MARK:- UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  }
  
  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    // Cell is removed from the collection view, cancel in progress requests for data for the specified index paths
    //print("did end cell: \(indexPath.row)")
    // This method gets called when we reload data
    if flickrArray.count > indexPath.row {
      let flickrModel = flickrArray[indexPath.row]
      self.imageFetcher.cancelImageLoadingFor(flickrModel: flickrModel)
    }
  }
  
  
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    // Cell is about to render, check whether `didEndDisplaying` method has cancelled
    // it's operation if so we can again enable it.
    //print("will display cell: \(indexPath.row)")
    let flickrModel = flickrArray[indexPath.row]
    let width = Int(getSizeOfCell(collectionView: collectionView).width)
    self.imageFetcher.getImageFor(flickrModel: flickrModel, width: width, priority: .veryHigh, index: indexPath.row) { (image) in
      DispatchQueue.main.async {
        //Check if the cell is the same cell that requested this image
        if cell.tag == indexPath.row {
          if let flickrCell = cell as? FlickrCell {
            flickrCell.imageView.image = image
          }
        }
      }
    }
    
    
    // Load more functionality
    if indexPath.row == (self.flickrArray.count - 1) {
      loadMore()
    }
  }
  
}

