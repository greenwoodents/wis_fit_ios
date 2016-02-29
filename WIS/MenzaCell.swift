//
//  MenzaCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 09.02.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit

class MenzaCell: UITableViewCell {

    var isObserving = false;
    @IBOutlet var title: UILabel!
    @IBOutlet var menu: UILabel!

    @IBOutlet var drawingView: DrawingView!
    
    class var expandedHeight: CGFloat { get { return 200 } }
    class var defaultHeight: CGFloat  { get { return 44  } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        drawingView.addSubview(DrawingView(red: 42, green: 42, blue: 124, course: "MNZ"))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func checkHeight() {
        menu.hidden = (frame.size.height < MenzaCell.expandedHeight)
    }
    
    func watchFrameChanges() {
        if !isObserving {
            addObserver(self, forKeyPath: "frameHeightChange", options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Initial], context: nil)
            isObserving = true;
        }
    }
    
    func ignoreFrameChanges() {
        if isObserving {
            removeObserver(self, forKeyPath: "frameHeightChange")
            isObserving = false;
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frameHeightChange" {
            checkHeight()
        }
    }
    
}
