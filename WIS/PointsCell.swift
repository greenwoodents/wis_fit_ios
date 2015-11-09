//
//  PointsCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 29.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import UIKit

class PointsCell: UITableViewCell {

    var cellAdded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class var expandedHeight: CGFloat { get { return 44 } }
    class var defaultHeight: CGFloat  { get { return 44  } }
    
    func checkHeight() {
    }
    
    
    func watchFrameChanges() {
        if !cellAdded {
            addObserver(self, forKeyPath: "frame", options: .New, context: nil)
            checkHeight()
            cellAdded = true
        }
    }
    
    func ignoreFrameChanges() {
        if cellAdded {
            removeObserver(self, forKeyPath: "frame")
            cellAdded = false
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            checkHeight()
        }
    }

    @IBOutlet var pointsForCourse: UILabel!
}
