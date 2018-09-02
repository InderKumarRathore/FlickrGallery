//
//  GalleryInteractor.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 02/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import Foundation


protocol GalleryBusinessLogic {
  
  /// Fetches the page from the flicker server
  ///
  /// - Parameters:
  ///   - isNewSearch: whether the search request is new or not
  ///   - text: search text
  func fetchPage(isNewSearch: Bool, text: String)

}


class GalleryInteractor {
  
  var presenter: GalleryPresentationLogic?
  
  /// Current page number for the flicker api, default = 1
  private var currentPage = 1
  
  /// Number of items per page
  private let itemsPerPage = 3 * 30 // 30 rows (or 90 images)
  
  /// Current search text
  private var searchText = ""
}

// MARK:- GalleryBusinessLogic
extension GalleryInteractor: GalleryBusinessLogic {
  func fetchPage(isNewSearch: Bool, text: String) {
    //Tell the presenter that we're fetching data from the server
    self.presenter?.fetchingData()
    
    self.searchText = text
    let searchApi = FlickrSearchApi()
    searchApi.getFlikrImages(pageNumber: self.currentPage, itemsPerPage: self.itemsPerPage, searchText: self.searchText, success: { [weak self] (flickrArray, currentPage, totalPages) in
      self?.currentPage = currentPage
      let canLoadNewPages = currentPage < totalPages
      //Tell the presenter that we've fetched the data
      self?.presenter?.dataFetched()
      // Tell the present to show new data
      self?.presenter?.presentFetchedObjects(isNewSearch: isNewSearch, flickrArray: flickrArray, canLoadNewPages: canLoadNewPages)
      
    }) {[weak self] (statusCode, error) in
      //Tell the presenter that we've fetched the data
      self?.presenter?.dataFetched()
      // Tell the persenter to show error
      self?.presenter?.showError(statusCode: statusCode, Error: error)
    }
  }
}



