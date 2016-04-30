//
//  HideableLabel.swift
//  goly
//
//  Created by Carson Moore on 4/30/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import UIKit

class HideableLabel: UILabel {
    var originalHeight: CGFloat?
    
    override init(frame: CGRect) {
        originalHeight = frame.height
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func hide() {
        if (!self.hidden) { originalHeight = self.frame.height }
        
        self.frame = CGRectMake(self.frame.minX, self.frame.minY, self.frame.width, 0)
        self.hidden = true
    }
    
    func show() {
        if let height = originalHeight {
            self.frame = CGRectMake(self.frame.minX, self.frame.minY, self.frame.width, height)
        }
        
        self.hidden = false
    }
}
