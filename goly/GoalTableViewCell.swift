//
//  GoalTableViewCell.swift
//  goly
//
//  Created by Carson Moore on 4/1/16.
//  Copyright © 2016 Carson C. Moore, LLC. All rights reserved.
//

import UIKit

class GoalTableViewCell: UITableViewCell {
    // Mark: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var lastCheckInLabel: UILabel!
    @IBOutlet weak var checkInButton: CheckInUIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
