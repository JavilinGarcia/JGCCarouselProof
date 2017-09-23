//
//  NumberView.swift
//  JGCCarouselProof
//
//  Created by Javier Garcia Castro on 23/9/17.
//  Copyright © 2017 Javier Garcia Castro. All rights reserved.
//

import UIKit

class NumberView: UIView {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        layoutIfNeeded()
    }
    
    // MARK: Public Methods

    func setForCurrentView() {
        label.textColor = UIColor.green.withAlphaComponent(0.8)
        label.font = label.font.withSize(26.0)
    }
    
    func setForNotCurrentView() {
        label.textColor = .gray
        label.font = label.font.withSize(15.0)
    }
    
    // MARK: Class Methods
    
    class func getWidth() -> CGFloat {
        return 50.0
    }
    
    class func getHeight() -> CGFloat {
        return 50.0
    }
}
