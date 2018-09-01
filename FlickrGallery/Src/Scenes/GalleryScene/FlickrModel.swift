//
//  FlickrModel.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 01/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//
import Foundation

class FlickrModel {
  
  func getFileName() -> String {
    return ""
  }
  
  func getDiskPath() -> String {
    return ""
  }
  
  func getDiskUrl() -> URL? {
    return URL(string: getDiskPath())
  }
}
