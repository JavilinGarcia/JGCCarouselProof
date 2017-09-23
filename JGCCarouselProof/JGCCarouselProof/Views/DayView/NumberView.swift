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
        
        backgroundColor = UIColor.green.withAlphaComponent(0.5)
        layer.cornerRadius = height/2
        layoutIfNeeded()
    }
    
    // MARK: Public Methods

    func setForCurrentView() {
        label.textColor = .white
        label.font = UIFont.init(name: label.font.fontName, size: 30.0)
        backgroundColor = UIColor.blue.withAlphaComponent(0.5)
    }
    
    func setForNotCurrentView() {
        label.textColor = .gray
        label.font = UIFont.init(name: label.font.fontName, size: 15.0)
        backgroundColor = UIColor.green.withAlphaComponent(0.5)
    }
    
    // MARK: Class Methods
    
    class func getWidth() -> CGFloat {
        return 50.0
    }
    
    class func getHeight() -> CGFloat {
        return 50.0
    }
}
