//
//  Meme.swift
//  MemeMe1.0 - Udacity-Nanodegree-Project-iOS-Developer
//
//  Created by Matthew Folbigg on 14/12/2020.
//

import Foundation
import UIKit

struct Meme {
    
    var topText: String
    var bottomeText: String
    var originalImage: UIImage
    var memeImage: UIImage
    
    init(top: String, bottom: String, background: UIImage, memeImage: UIImage) {
        self.topText = top
        self.bottomeText = bottom
        self.originalImage = background
        self.memeImage = memeImage
    }
}
