//
//  GalleryPresenter.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 02/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import Foundation
import UIKit

protocol GalleryPresentationLogic {
  func presentFetchedObjects(isNewSearch: Bool, flickrArray: [FlickrModel], canLoadNewPages: Bool)
  func fetchingData()
  func dataFetched()
  func showError(statusCode: Int, Error: Error?)
}

class GalleryPresenter {
  weak var viewController: GalleryDisplayLogic?
}

// MARK:- GalleryPresentationLogic
extension GalleryPresenter: GalleryPresentationLogic {
  
  func presentFetchedObjects(isNewSearch: Bool, flickrArray: [FlickrModel], canLoadNewPages: Bool) {
    DispatchQueue.main.async {
      self.viewController?.displayFetchedObjects(isNewSearch: isNewSearch, flickrArray: flickrArray, canLoadMore: canLoadNewPages)
    }
  }
  
  func fetchingData() {
    DispatchQueue.main.async {
      self.viewController?.showLoader()
    }
  }
  
  func dataFetched() {
    DispatchQueue.main.async {
      self.viewController?.hideLoader()
    }
  }
  
  func showError(statusCode: Int, Error: Error?) {
    DispatchQueue.main.async {
    self.viewController?.showError("Something went wrong. Please see the console for more informartion. This alert can be customized based on different error codes.")
    }
  }
}
