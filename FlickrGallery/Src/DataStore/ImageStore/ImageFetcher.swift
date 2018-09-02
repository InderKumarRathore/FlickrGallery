//
//  ImageFetcher.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 02/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

/// Gets the image for the url.
/// First it looks into the NSCache, then on disk and at last it fetches the data
/// from the server
class ImageFetcher {
  
  /// Operation queue for downloading the Images from the server
  let operationQueue = OperationQueue()
  
  /// Keeps the images in memory for cache
  let imageCache = NSCache<NSString, UIImage>()
  
  /// Default session for all image loading from the serverb
  let session = URLSession(configuration: .default)
  
  /// Keeps the operation that are in progress, we can also get the operation from the
  /// operation queue but that's CPU intensive especially when we need to canecel array of
  /// operations. Then complexity becomes O(n^2) and using dict it's O(n)
  var operationsInProgress = [String : ImageDownloadOperation]()
  
  /// Holds the completion handler
  /// We've having one competion handler for on key, we can also make it array so that
  /// multiple completion handlers can be invoked but this is not need now, so having
  /// one to one maping
  var completionHandlers = [String : ((UIImage) -> Void)]()
  
  /// Serial queue to syncronise the access of `operationsInProgress`,`imageCache`, `completionHandler` and `operationQueue`
  let serialDispatchQueue = DispatchQueue(label: "ImageFetcher", qos: .userInitiated)
  
  
  /// Initilizer
  ///
  /// - Parameters:
  ///   - concurrentOperations: number of concurrent operations for image downloading
  ///   - cacheImageCount: max number of images to be cached
  init(concurrentOperations: Int, cacheImageCount: Int) {
    self.operationQueue.maxConcurrentOperationCount = concurrentOperations
    self.imageCache.countLimit = cacheImageCount
  }
  
  
  /// Gets the image a flickr model form cache/disk/network
  ///
  /// - Parameters:
  ///   - flickrModel: model
  ///   - width: thumbnail width, if nil the returns the full image
  ///   - completionHandler: completion handler
  func getImageFor(flickrModel: FlickrModel, width: Int?, priority: Operation.QueuePriority , index: Int, completionHandler: ((UIImage) -> Void)?) {
//    print("operations:\(operationQueue.operations.count) | dict:\(operationsInProgress.count)")
    serialDispatchQueue.async { [weak self] in
      if let weakSelf = self {
        // Get the file name
        let fileName = flickrModel.getFileName()
        
        // So first we'll check the image cache
        if let image = weakSelf.imageCache.object(forKey: fileName as NSString) {
          // Wooooo! we found the image in the cache, return this image
          //print("Image found in cache:\(flickrModel.getFileName())")
          // Remove completion handler if any
          completionHandler?(image)
        }
        else if weakSelf.operationsInProgress[fileName] == nil {
          // Operation is not in progress then either file exists at path or don't
          if FileManager.default.fileExists(atPath: flickrModel.getDiskPath()) {
            // Wooooo! we found the image on disk, return this image
            //print("Image found on disk:\(flickrModel.getFileName())")
            if let fileUrl = flickrModel.getDiskUrl() {
              if let scaledImage = weakSelf.downSampleImage(width: width, fileUrl: fileUrl) {
                // Set the image in image cache
                self?.imageCache.setObject(scaledImage, forKey: fileName as NSString)
                // Call the completion handler
                completionHandler?(scaledImage)
              }
            }
          }
          else {
            // File don't exits and operation is not in progresss. Add operation ASAP!
            //print("Getting image from network:\(flickrModel.getFileName())")
            // Create the completion handler
            let imageOperationHandler = weakSelf.getCompletionHandler(width: width, index: index, fileName: fileName)
            // Create the operation
            let operation = ImageDownloadOperation(flickrModel: flickrModel, session: weakSelf.session, completionHandler: imageOperationHandler)
            // Set the priority
            operation.queuePriority = priority
            // Syncronize the `operationsInProgress`
            weakSelf.serialDispatchQueue.async { [weak self] in
              operation.index = index
              // Add the completion handler
              // Save the completion handler
              if let handler = completionHandler {
                weakSelf.completionHandlers[fileName] = handler
              }
              // Add operation to dictionay and queue
              self?.operationsInProgress[flickrModel.getFileName()] = operation
              self?.operationQueue.addOperation(operation)
            }
          }
        }
        else {
          // Operation is already in progress now if we've a completion handler
          // then add it to dict
          print("Operation already in progress: \(index) | CH:\(completionHandler == nil ? "nil"  : "non-nil")")
          if let handler = completionHandler {
            self?.completionHandlers[fileName] = handler
          }
        }
      }
    }
  }
  
  
  /// Completion handler for the ImageDownloadOperation, this code was repetative
  /// thus added a method for it
  ///
  /// - Parameters:
  ///   - width: width for the image to down sample
  ///   - fileName: fileName
  ///   - completionHandler: completion handler
  /// - Returns: completion handler
  private func getCompletionHandler(width: Int?, index: Int, fileName: String) -> ImageDownloadOperation.CompletionHandlerClosure {
    return { [weak self] (success, flickrModel) in
      if success {
        // File have been saved to disk, now we've to get it and
        // give the image data back
        // Down sample the image based on the width
        print("Operation Completed, operations:\(String(describing: self?.operationQueue.operations.count)) | for :\(index)")
        var scaledImage: UIImage? = nil
        if let fileUrl = flickrModel.getDiskUrl() {
          scaledImage = self?.downSampleImage(width: width, fileUrl: fileUrl)
        }
        self?.serialDispatchQueue.async { [weak self] in
          // Remove the operation from the progress oepration
          self?.operationsInProgress.removeValue(forKey: fileName)
          // Add this file to cache
          if let image = scaledImage {
            // Set the image in image cache
            self?.imageCache.setObject(image, forKey: fileName as NSString)
            // Call the completion handler
            if let handler = self?.completionHandlers.removeValue(forKey: fileName) {
              handler(image)
            }
          }
        }
      }
    }
  }
  
  
  /// Downsamples the image to the specified width
  ///
  /// - Parameters:
  ///   - width: max width, if nil then returns the full size image
  ///   - fileUrl: file url from where file is to be loaded
  /// - Returns: UIImage
  private func downSampleImage(width: Int?, fileUrl: URL) -> UIImage? {
    if let maxWidth = width { // we wan't to down sample
      if let imageSource = CGImageSourceCreateWithURL(fileUrl as CFURL, nil) {
        let options: [NSString : Any] = [
          kCGImageSourceThumbnailMaxPixelSize: maxWidth,
          kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        if let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) {
          return UIImage(cgImage: scaledImage)
        }
      }
      // Unable to down sample
      return nil
    }
    else { // return full size image
      return UIImage(contentsOfFile: fileUrl.path)
    }
  }
  
  
  /// Clears the image cache, useful in cases when you receive memory warnings
  func clearCache() {
    self.serialDispatchQueue.async { [weak self] in
      self?.imageCache.removeAllObjects()
    }
  }
  
  /// Cancels the opertaion that is downloading the image for `flickrModel`
  ///
  /// - Parameter flickrModel: model for which operation needs to be cancelled
  func cancelImageLoadingFor(flickrModel: FlickrModel) {
    self.serialDispatchQueue.async { [weak self] in
      let key = flickrModel.getFileName()
      if let operation = self?.operationsInProgress[key] {
        operation.cancel()
        self?.operationsInProgress.removeValue(forKey: key)
      }
    }
  }
  
}
