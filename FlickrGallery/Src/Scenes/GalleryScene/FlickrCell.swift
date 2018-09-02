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
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.imageView.image = #imageLiteral(resourceName: "placeholder-image")
  }
  
  
}
