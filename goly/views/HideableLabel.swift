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
        if (!self.isHidden) { originalHeight = self.frame.height }
        for c in self.constraints {
            if (c.identifier == "HideableHeight") {
                c.constant = 0
                self.layoutIfNeeded()
            }
        }
        // self.transform = CGAffineTransformMakeScale(1, 0)
        self.isHidden = true
    }
    
    func show() {
        for c in self.constraints {
            if (c.identifier == "HideableHeight") {
                
                c.constant = requiredHeight()
                self.layoutIfNeeded()
            }
        }
        
        self.isHidden = false
        
    }
    
    // http://stackoverflow.com/questions/25180443/adjust-uilabel-height-to-text
    func requiredHeight() -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.height
    }
}
