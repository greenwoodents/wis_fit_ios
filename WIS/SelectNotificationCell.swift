//
//  SelectNotificationCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 01.12.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class SelectNotificationCell: MGSwipeTableCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var detail: UILabel!
    @IBOutlet var expandSymbol: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
