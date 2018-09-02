//
//  GalleryViewControllerTests.swift
//  FlickrGalleryTests
//
//  Created by Inder Kumar Rathore on 02/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import XCTest
@testable import FlickrGallery

class GalleryViewControllerTests: XCTestCase {
  
  // MARK:
  class GalleryInteractorSpy: GalleryBusinessLogic {
    var isFetchPageCalled = false
    
    func fetchPage(isNewSearch: Bool, text: String?) {
      isFetchPageCalled = true
    }
  }
  
  var sut: GalleryViewController!
  var window: UIWindow!
  
  override func setUp() {
    super.setUp()
    window = UIWindow()
    let bundle = Bundle.main
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    sut = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
    
    window.addSubview(sut.view)
    RunLoop.current.run(until: Date())
  }
  
  override func tearDown() {
    window = nil
    super.tearDown()
  }
  
  /// View controller should call interector's fetch page
  func testSearchNewText() {
    let galleryInteractor = GalleryInteractorSpy()
    sut.interactor = galleryInteractor
    
    let searchBar = UISearchBar(frame: .zero)
    searchBar.text = "kittens"
    sut.searchBarSearchButtonClicked(searchBar)
    
    XCTAssert(galleryInteractor.isFetchPageCalled, "Should ask interactor to serach")

  }
}
