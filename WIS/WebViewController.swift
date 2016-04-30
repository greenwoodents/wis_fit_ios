//
//  WebViewController.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 11.02.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    private let url = "https://wis.fit.vutbr.cz/FIT/st/studygs-l.php?id=" //175&sem=L
    private var semester: String {
        return "L"
    }
    
    
    @IBOutlet var WebView: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var selectClassButton: UIButton!
    @IBAction func selectClass(sender: UIButton) {
        selectClass()
    }
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showPopOver" {
//            let vc = segue.destinationViewController
//            let controller = vc.popoverPresentationController
//            if controller != nil { controller?.delegate = self }
//        }
//    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeSchedule:", name: "loadAddressURLID", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        if loggedIn {
//            self.navigationController!.navigationBar.subviews[1].subviews[1].hidden = false
            if let myClass = defaults.stringForKey("class") {
                selectClassButton.setTitle(myClass, forState: .Normal)
                loadAddressURL(myClass)
            } else {
                selectClassButton.setTitle("2BIB", forState: .Normal)
                loadAddressURL()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupSubviews() {
        WebView.scalesPageToFit = true
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.lightGrayColor()
        selectClassButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        selectClassButton.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        selectClassButton.setBackgroundColor(UIColor.lightGrayColor(), forState: .Normal)
        selectClassButton.setBackgroundColor(UIColor.lightGrayColor(), forState: .Highlighted)
    }
    
    func selectClass() {
        
        let popoverContent = (self.storyboard?.instantiateViewControllerWithIdentifier("popoverViewController"))! as! PopoverViewController
        _ = popoverContent.view
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = popoverContent.classPickerOutlet.frame.size
        popover!.permittedArrowDirections = .Down
        popover!.delegate = self
        popover!.sourceView = self.view
        popover!.sourceRect = selectClassButton.frame
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func changeSchedule(notification: NSNotification) {
        if loggedIn {
            let userInfo = notification.userInfo as! [String:String]
            loadAddressURL(userInfo["class"]!)
            selectClassButton.setTitle(userInfo["class"]!, forState: .Normal)
        }
    }
    
    
    func loadAddressURL(var year: String = Class.Osobný.rawValue) {
        if defaults.boolForKey("loggedIn") {
            self.activityIndicator.startAnimating()
            switch (year) {
                case "1BIA": year = Class.BIA1.rawValue; break
                case "1BIB": year = Class.BIB1.rawValue; break
                case "2BIA": year = Class.BIA2.rawValue; break
                case "2BIB": year = Class.BIB2.rawValue; break
                case "3BIT": year = Class.BIT3.rawValue; break
                case "Osobný rozvrh": year = Class.Osobný.rawValue; break
                default: year = Class.BIB2.rawValue; break
            }
            
            let customURL = year == Class.Osobný.rawValue ? year : url + year + "&sem=" + semester
            NetworkManager.sharedInstace.defaultManager.request(.GET, customURL)
            .authenticate(user: defaults.stringForKey("login")!, password: defaults.stringForKey("passwd")!)
            .responseString { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let newValue = value.stringByReplacingOccurrencesOfString("\n", withString: "")
                        let htmlWithTable = matchesForRegexInText("<table border=1.*[Last modification|Poslední aktualizace]", text: newValue).first!
                        let finalHtmlWithTable = htmlWithTable.stringByReplacingOccurrencesOfString("Last modification", withString: "")
                        
                        print(finalHtmlWithTable)
                        
                        self.WebView.loadHTMLString(finalHtmlWithTable, baseURL: NSURL(string: "https://wis.fit.vutbr.cz")!)
                        self.activityIndicator.stopAnimating()
                    }
                case .Failure(let error):
                    print(error)
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


