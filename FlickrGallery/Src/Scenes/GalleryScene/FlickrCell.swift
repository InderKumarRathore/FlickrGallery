//
//  FlickrCell.swift
//  FlickrGallery
//
//  Created by Inder Kumar Rathore on 01/09/18.
//  Copyright © 2018 Inder Kumar Rathore. All rights reserved.
//

import UIKit

class FlickrCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var numberLabel: UILabel!
  
  /// Cell id, usually the indexPath.row. We need this to identify whether the data
  /// that has been downloaded belongs to the same cell or not. Since number of cells remains
  /// fixed in collection view and these are reused hence we need some machanism to identify
  /// the cell. Default is -1
  var cellId = -1
}
