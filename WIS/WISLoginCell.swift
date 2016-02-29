//
//  WISLoginCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 24.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SwiftyJSON

class WISLoginCell: UITableViewCell, UITextFieldDelegate {

    private var lg = ""
    private var pswd = ""
    var buttonClicked = true
    var cellAdded = false
    var type = "login"
    
    
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var login: UITextField!
    @IBOutlet var passwd: UITextField!
    
    
    func passwdFirstResponder() {
        passwd.becomeFirstResponder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.login.delegate = self
        self.passwd.delegate = self
        passwd.secureTextEntry = true
        activityIndicator.hidesWhenStopped = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    // MARK: Expand cell
    
    class var expandedHeight: CGFloat { get { return 120 } }
    class var defaultHeight: CGFloat  { get { return 37  } }
    
    func checkHeight() {
        login.hidden = (frame.size.height < WISLoginCell.expandedHeight)
        passwd.hidden = (frame.size.height < WISLoginCell.expandedHeight)
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
    
    deinit {
        ignoreFrameChanges()
    }
    
    
    // MARK: Textfield
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == login {
            passwd.becomeFirstResponder()
        } else if textField == passwd {
            textField.resignFirstResponder()
            if !login.text!.isEmpty && !passwd.text!.isEmpty {
                

                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.startAnimating()
                    }
                    NetworkManager.sharedInstace.defaultManager.request(.GET, "https://wis.fit.vutbr.cz/FIT/st/get-coursesx.php") //presunut do ViewController a
                        .authenticate(user: self.login.text!, password: self.passwd.text!)
                        .response { response in
                            if let error = response.3 {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.activityIndicator.stopAnimating()
                                }
                                ShakeAnimation.animate(self)
                                print(__LINE__)
                                print(__FUNCTION__)
                                print(error)
                            } else {
                                let notifManager = NotificationManager()
                                let XMLstring = NSString(data: response.2!, encoding: NSUTF8StringEncoding)
                                
                                let defaults = NSUserDefaults.standardUserDefaults()
                                defaults.setObject(self.login.text!, forKey: "login")
                                defaults.setObject(self.passwd.text!, forKey: "passwd")
                                defaults.setObject(XMLstring, forKey: "xml")
                                defaults.setBool(true, forKey: "loggedIn")
                                defaults.synchronize()
                                self.login.text?.removeAll()
                                self.passwd.text?.removeAll()
                                notifManager.saveNotifications(XMLstring as! String)
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.activityIndicator.stopAnimating()
                                }
                                NSNotificationCenter.defaultCenter().postNotificationName("downloadInboxID", object: nil)
                                NSNotificationCenter.defaultCenter().postNotificationName("fillMostRecentNotifsID", object: nil)
                                NSNotificationCenter.defaultCenter().postNotificationName("displayNavigationElementsID", object: nil)
                            }
                        }
                } // dispatch end
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                    Alamofire.request(.GET, "http://www.vasazubarka.sk/Tsc/Skusky.json")
                    .responseJSON { response in
                        switch response.result {
                        case .Success:
                            if let value = response.result.value {
                                NotificationManager().parseAndSaveExternalSources(value)
                                
                            }
                        case .Failure(let error):
                            print(__LINE__)
                            print(__FUNCTION__)
                            print(error)
                            
                        }
                    }
                }
                
            } else {
                ShakeAnimation.animate(self)
            }
        }
        return true
    }
}
