//
//  String+JGCExtension.swift
//  JGCCarouselProof
//
//  Created by Javier Garcia Castro on 23/9/17.
//  Copyright © 2017 Javier Garcia Castro. All rights reserved.
//

import Foundation

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
    
    func substring(to: Int) -> String {
        return self.substring(to: self.characters.index(self.startIndex, offsetBy: to))
    }
    
    var length: Int {
        return self.characters.count
    }
}
