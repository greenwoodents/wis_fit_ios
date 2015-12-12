//
//  FBLoginCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 23.11.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class FBLoginCell: UITableViewCell {
    
    var dict: NSDictionary!
    let loginButton = FBSDKLoginButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loginButton.center = self.center
        self.addSubview(loginButton)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


    
    
//    @IBAction func btnFBLoginPressed(sender: AnyObject) {
//        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
//        fbLoginManager .logInWithReadPermissions(["email"], handler: { (result, error) -> Void in
//            if (error == nil){
//                let fbloginresult : FBSDKLoginManagerLoginResult = result
//                if(fbloginresult.grantedPermissions.contains("email"))
//                {
//                    self.getFBUserData()
//                    fbLoginManager.logOut()
//                }
//            }
//        })
//    }
//    
//    func getFBUserData(){
//        if((FBSDKAccessToken.currentAccessToken()) != nil){
//            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
//                if (error == nil){
//                    self.dict = result as! NSDictionary
//                    print(result)
//                    print(self.dict)
//                    NSLog(self.dict.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String)
//                }
//            })
//        }
//    }
}
