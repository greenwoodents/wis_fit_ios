//
//  PostponeViewController.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 30.01.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit

class PostponeViewController: UIViewController {

    var currentIndexPath: NSIndexPath? = nil
    var abc = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        let blur = UIBlurEffect(style: .Dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = view.frame
        
        let vibrancy = UIVibrancyEffect(forBlurEffect: blur)
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        vibrancyView.frame = view.frame
        
        let returnBackButton = UIButton(frame: view.frame)
        returnBackButton.addTarget(self, action: "back:", forControlEvents: .TouchUpInside)
        vibrancyView.addSubview(returnBackButton)
        
        let button = UIButton(frame: CGRectMake(0, 0, 150, 50))
        button.setTitle("Odložiť o minútu", forState: .Normal)
        button.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        button.center = view.center
        button.layer.borderWidth = CGFloat(2.0)
        button.layer.borderColor = UIColor.whiteColor().CGColor
        vibrancyView.addSubview(button)
        
        blurView.contentView.addSubview(vibrancyView)
        view.addSubview(blurView)
    }
    
    func back(sender: UIButton) {
        self.presentingViewController!.dismissViewControllerAnimated(true){}
        NSNotificationCenter.defaultCenter().postNotificationName("postponeViewDismissedID", object: self, userInfo: ["section":currentIndexPath!.section, "row":currentIndexPath!.row, "postponeType":0])
    }

    func pressed(sender: UIButton) {
        self.presentingViewController!.dismissViewControllerAnimated(true){}
        NSNotificationCenter.defaultCenter().postNotificationName("postponeViewDismissedID", object: self, userInfo: ["section":currentIndexPath!.section, "row":currentIndexPath!.row, "postponeType":1])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
