//
//  FlickrSearchApi.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 02/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import Foundation

class FlickrSearchApi {
  typealias SuccessClosure = ([FlickrModel], _ currentPage:Int, _ totalPages: Int) -> Void
  typealias FailureClosure = (_ statusCode: Int, _ error: Error?) -> Void
  
  /// Fetches the data from the flicker API.
  /// Fixme: Hardcoing the key here.
  /// We can put the key at some other places, but lets finish the taks first
  ///
  /// - Parameters:
  ///   - pageNumber: page number starts from 1
  ///   - itemsPerPage: number of items per page
  ///   - searchText: text that has been queried for
  ///   - success: success call  back
  ///   - failed: failiure call back
  func getFlikrImages(pageNumber: Int, itemsPerPage: Int, searchText: String,
                      success:@escaping SuccessClosure,
                      failed:@escaping FailureClosure) {
    // Encode the search text parameter
    if let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
      // Create the url string
      let urlStr = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=\(encodedText)&page=\(pageNumber)&per_page=\(itemsPerPage)"
      // Create the url object
      if let url = URL(string: urlStr) {
        // Create session
        let session = URLSession(configuration: .default)
        // Create data task
        let dataTask = session.dataTask(with: url) { (data, response, error) in
          if let res = response as? HTTPURLResponse {
            if error == nil && res.statusCode == 200 {
              // Success, convert the data into Array of objects
              if let data = data {
                if let jsonObject = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: AnyObject] {
                  // Parse the json object
                  if let photos = jsonObject["photos"] as? [String : AnyObject],
                    let currentPage = photos["page"] as? Int,
                    let totalPages = photos["pages"] as? Int {
                    // Array to hold the flickr objects
                    var flickrArray = [FlickrModel]()
                    if let photoArray = photos["photo"] as? [[String : AnyObject]] {
                      for photo in photoArray {
                        let id = photo["id"] as? String
                        let secret = photo["secret"] as? String
                        let server = photo["server"] as? String
                        let farm = photo["farm"] as? Int
                        
                        if id != nil && secret != nil && server != nil && farm != nil {
                          let flickrModel = FlickrModel(id: id!, secret: secret!, server: server!, farm: farm!)
                          flickrArray.append(flickrModel)
                        }
                      }
                    }
                    //Call the success handler
                    success(flickrArray, currentPage, totalPages)
                  }
                  else {
                    failed(10013, nil) // Couln't parse photos object
                  }
                }
                else {
                  failed(10013, nil) //Json not valid
                }
              }
              else {
                failed(10012, nil) // Couln't get the response data
              }
            }
            else {
              failed(res.statusCode, error)
            }
          }
          else {
            failed(10011, error) // Couln't get the response
          }
        }
        // Start the task
        dataTask.resume()
      }
      else {
        failed(10009, nil) // Couldn't form url
      }
    }
    else {
      failed(10010, nil) // Couldn't encode search text
    }
  }
}
