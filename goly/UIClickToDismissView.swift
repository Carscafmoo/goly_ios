//
//  UIClickToDismissView.swift
//  goly
//
//  Created by Carson Moore on 4/30/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import UIKit
class UIClickToDismissView: UIView {
    var currentTextField: UITextField?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let ctf = currentTextField {
            if (ctf.canResignFirstResponder()) { ctf.resignFirstResponder() }
        }
    }
    
}
