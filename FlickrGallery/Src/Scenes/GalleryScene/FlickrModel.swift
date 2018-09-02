//
//  FlickrModel.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 01/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//
import Foundation

struct FlickrModel {
  var id: String
  var secret: String
  var server: String
  var farm: Int
  
  
  /// Unique file name
  ///
  /// - Returns: file name
  func getFileName() -> String {
    return "\(farm)_\(server)_\(id)_\(secret).jpg"
  }
  
  
  /// Gets the path for image file
  ///
  /// - Returns: path for image file
  func getDiskPath() -> String {
    let tempDir = NSTemporaryDirectory()
    let flickrDir = "FlickrData"
    let fullDirPath = "\(tempDir)\(flickrDir)"
    try? FileManager.default.createDirectory(atPath: fullDirPath, withIntermediateDirectories: true, attributes: nil)
    return "\(fullDirPath)/\(getFileName())"
  }
  
  
  /// Gets the disk url for the file
  ///
  /// - Returns: disk url
  func getDiskUrl() -> URL? {
    return URL(fileURLWithPath: getDiskPath())
  }
}
