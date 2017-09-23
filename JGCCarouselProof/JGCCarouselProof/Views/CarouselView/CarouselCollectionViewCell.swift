//
//  CarouselCollectionViewCell.swift
//  JGCCarouselProof
//
//  Created by Javier Garcia Castro on 23/9/17.
//  Copyright © 2017 Javier Garcia Castro. All rights reserved.
//

import UIKit

let CarouselCollectionViewCellIdentifier = "CarouselCollectionViewCellIdentifier"

class CarouselCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var circleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    class func reuseIdentifier() -> String {
        return CarouselCollectionViewCellIdentifier
    }
}




