//
//  SimpleNotificationCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 09.11.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class SimpleNotificationCell: MGSwipeTableCell, MGSwipeTableCellDelegate {
    
    var course: String = ""
    var mainText: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
