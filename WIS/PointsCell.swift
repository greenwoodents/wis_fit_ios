//
//  PointsCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 29.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import UIKit

class PointsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet var pointsForCourse: UILabel!
}
