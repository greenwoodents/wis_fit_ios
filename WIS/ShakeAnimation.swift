//
//  ShakeAnimation.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 11.12.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import UIKit

class ShakeAnimation {
    class func animate(cell: UITableViewCell) {
        let position: CGPoint = cell.center
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(position.x, position.y))
        path.addLineToPoint(CGPointMake(position.x - 30, position.y))
        path.addLineToPoint(CGPointMake(position.x + 30, position.y))
        path.addLineToPoint(CGPointMake(position.x - 10, position.y))
        path.addLineToPoint(CGPointMake(position.x + 10, position.y))
        path.addLineToPoint(CGPointMake(position.x, position.y))
        let positionAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.path = path.CGPath
        positionAnimation.duration = 0.5
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        CATransaction.begin()
        cell.layer.addAnimation(positionAnimation, forKey: nil)
        CATransaction.commit()
    }
}