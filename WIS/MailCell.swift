//
//  MailCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 15.02.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit

class MailCell: UITableViewCell {

    @IBOutlet var from: UILabel!
    @IBOutlet var subject: UILabel!
    @IBOutlet var body: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
