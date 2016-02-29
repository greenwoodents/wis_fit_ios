//
//  drawingView.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 26.01.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit

class DrawingView: UIView {
    
    var course: String?
    
    
    
    
    init(red: Int, green: Int, blue: Int, course: String) {
        self.course = course.uppercaseString
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.backgroundColor = UIColor.whiteColor()
        frame = CGRectMake(0, 0, 43, 43)
        createColor(course, light: false)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        if let crse = course {
            createColor(crse, light: false).setFill()
        } else {
            UIColor.greenColor().setFill()
        }
        path.fill()
    }
}

public func createColor(course: String, light: Bool) -> UIColor {
    let tmp = course.unicodeScalars
    let red = (Double(tmp[tmp.startIndex].value) - 65)/25 as Double
    let green = (Double(tmp[tmp.startIndex.advancedBy(1)].value) - 65)/25
    let blue = (Double(tmp[tmp.startIndex.advancedBy(2)].value) as Double - 65)/25
    return light ?  UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 0.05) :
                    UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 0.5)
}