//
//  GraphicalNotificationCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 26.01.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class GraphicalNotificationCell: MGSwipeTableCell, MGSwipeTableCellDelegate {

    @IBOutlet var drawingView: UIView!
    @IBOutlet var primaryTextLabel: UILabel!
    @IBOutlet var secondaryTextLabel: UILabel!
    
    var course: String = ""
    var mainText: String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        primaryTextLabel.adjustsFontSizeToFitWidth = true
        secondaryTextLabel.adjustsFontSizeToFitWidth = true
        drawingView.addSubview(DrawingView(red: 42, green: 42, blue: 124, course: course))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func redraw() {
        drawingView.addSubview(DrawingView(red: 42, green: 42, blue: 124, course: course))
        let courseAbbrvLabel = UILabel(frame: CGRectMake(0 ,0, 40, 40))
        courseAbbrvLabel.center = drawingView.subviews[0].center
        courseAbbrvLabel.textAlignment = NSTextAlignment.Center
        courseAbbrvLabel.text = course
        courseAbbrvLabel.textColor = UIColor.whiteColor()
        drawingView.addSubview(courseAbbrvLabel)
    }
    
    func redrawWithColorBackground() {
        let circle = DrawingView(red: 42, green: 42, blue: 124, course: course)
        circle.backgroundColor = createColor(course, light: true)
        drawingView.addSubview(circle)
        let courseAbbrvLabel = UILabel(frame: CGRectMake(0 ,0, 40, 40))
        courseAbbrvLabel.center = drawingView.subviews[0].center
        courseAbbrvLabel.textAlignment = NSTextAlignment.Center
        courseAbbrvLabel.text = course
        courseAbbrvLabel.textColor = UIColor.whiteColor()
        drawingView.addSubview(courseAbbrvLabel)
    }
}
