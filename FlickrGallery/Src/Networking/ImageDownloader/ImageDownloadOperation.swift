//
//  ImageDownloadOperation.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 01/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import Foundation

class ImageDownloadOperation: Operation {
  
  /// Holds the infomation about the chunk that needs to be downloaded
  private let flickrModel: FlickrModel
  
  // TODO: This is for debugging purpose and can be removed
  var index = 0
  
  /// URL Sessoin
  private let session: URLSession
  
  /// Download task
  private var downloadTask: URLSessionDownloadTask? = nil
  
  typealias CompletionHandlerClosure = (_ successFullySaved: Bool, FlickrModel) -> Void
  private var completionHandler: CompletionHandlerClosure
  
  
  init(flickrModel: FlickrModel, session: URLSession, completionHandler: @escaping CompletionHandlerClosure) {
    self.flickrModel = flickrModel
    self.session = session
    self.completionHandler = completionHandler
    super.init()
  }
  
  
  override func start() {
    // Always check for cancellation before launching the task.
    if isCancelled {
      self.isFinished = true
      return
    }
    
    // Operation is not canceled, setup the task
    if let url = URL(string: "http://farm\(flickrModel.farm).static.flickr.com/\(flickrModel.server)/\(flickrModel.id)_\(flickrModel.secret).jpg") {
      self.downloadTask = self.session.downloadTask(with: url, completionHandler: {[weak self] (url, response, error) in
        // Boolean to tell whether data has been successfuly donwloaded and saved to disk
        var success = false
        // Check for error and status code
        if error == nil {
          if let res = response as? HTTPURLResponse {
            if res.statusCode == 200 {
              // Now we have successfully downloaded the  file.
              if let srcUrl = url, let destUrl = self?.flickrModel.getDiskUrl() {
                do {
                  try FileManager.default.moveItem(at: srcUrl, to: destUrl)
                  success = true
                }
                catch {
                  print("Failed to save the file:\(error)")
                }
              }
            }
          }
        }
        
        // Mark the operation completed
        self?.completeOperation()
        
        // Notify that operation has finished
        if let completionHandler = self?.completionHandler {
          completionHandler(success, self!.flickrModel) // we have self here so unwraping it
        }
      })
    }
    // Call the main
    main()
  }
  
  override func main() {
    if let task = self.downloadTask {
      // Resume the task
      task.resume()
    }
    else {
      // There was no task hence mark it complete
      completeOperation()
    }
  }

  
  // MARK:- Async URLSession
  // I'm overriding these methods so that I can handle async url session.
  
  // ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
  
  /// Lock to manage the thead safety as described here: https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html#//apple_ref/doc/uid/TP40008091-CH101-SW8
  /// Few excerpt is below
  /// `Your implementations of these methods must be safe to call from other threads simultaneously. You must also generate the appropriate KVO notifications for the expected key paths when changing the values reported by these methods.`
  private let stateLock = NSLock()
  
  
  override public var isAsynchronous: Bool { return true }
  
  private var _executing: Bool = false
  private var _finished: Bool = false
  
  
  override public var isExecuting: Bool {
    get {
      return self._executing
    }
    set {
      willChangeValue(forKey: "isExecuting")
      self.stateLock.lock()
      self._executing = newValue
      self.stateLock.unlock()
      didChangeValue(forKey: "isExecuting")
    }
  }
  
  override public var isFinished: Bool {
    get {
      return self._finished
    }
    set {
      willChangeValue(forKey: "isFinished")
      self.stateLock.lock()
      self._finished = newValue
      self.stateLock.unlock()
      didChangeValue(forKey: "isFinished")
    }
  }
  
  func completeOperation() {
    self.isExecuting = false
    self.isFinished = true
  }
  
  override func cancel() {
    self.downloadTask?.cancel()
    super.cancel()
  }
}
