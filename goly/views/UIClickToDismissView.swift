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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let ctf = currentTextField {
            if (ctf.canResignFirstResponder) { ctf.resignFirstResponder() }
        }
    }
    
}
