//
//  WISLoginCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 24.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import UIKit
import CoreData

class WISLoginCell: UITableViewCell, UITextFieldDelegate {

    private var lg = ""
    private var pswd = ""
    var buttonClicked = true
    var cellAdded = false
    var type = "login"
    
    let MyKeychainWrapper = KeychainWrapper()
    
    
    @IBOutlet var login: UITextField!
    @IBOutlet var passwd: UITextField!
    
    
    func passwdFirstResponder() {
        passwd.becomeFirstResponder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.login.delegate = self
        self.passwd.delegate = self
        login.tag = 1
        passwd.tag = 2  //mozem vymazat
        passwd.secureTextEntry = true
        // Initialization code
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
        print("deinit")
        ignoreFrameChanges()
    }
    
    // MARK: Textfield
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == login {
            passwd.becomeFirstResponder()
        } else if textField == passwd {
            textField.resignFirstResponder()
            if login.text! != "" && passwd.text! != "" {
                
                NetworkManager.sharedInstace.defaultManager.request(.GET, "https://wis.fit.vutbr.cz/FIT/st/get-coursesx.php") //presunut do ViewController a
                    .authenticate(user: login.text!, password: passwd.text!)
                    .response { response in
                        if let _ = response.3 {
                            print("error")
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
                            if notifManager.parse(XMLstring as! String) {
//                                notifManager.printStructs()
                                
                                notifManager.saveData()
//                                    notifManager.update("as") //asdasdasd!!!!!! TOTO UPRAVIT
                                    notifManager.createNotificationStack()
                                NSNotificationCenter.defaultCenter().postNotificationName("remoteRefreshID", object: nil)
                            }
                            
                            
                            
                        }
                    }
            }
        }
        return true
    }
}
