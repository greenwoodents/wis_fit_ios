//
//  ViewController.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 12.10.2015.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import UIKit
import Fuzi
import Alamofire
import CoreData

class ViewController: UIViewController, NSURLSessionDelegate {
    
    
    
    //var XML: Result<AnyObject>? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NetworkManager.sharedInstace.defaultManager.request(.GET, "https://wis.fit.vutbr.cz/FIT/st/get-courses.php")
                    .authenticate(user: "xscavn00", password: "have6cimun")
            .response {response in
                
                if let _ = response.3 {
                    NSLog(response.3.debugDescription)
                } else {
                    let XMLstring = NSString(data: response.2!, encoding: NSUTF8StringEncoding)
                    if let XMLString = XMLstring {
                        print(XMLString)
                    }
                }
                
                
                
        }
    }
//            .response { request, response, data, error in
//                let XMLString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                print(XMLString)
//                print(data!)
        
//                do {
//                    let document = try XMLDocument(string: stringFromData as String)
//                    if let root = document.root {
//                        for element in root.children {
//                            print("\(element.tag!): \(element.attributes)")
//                        }
//                    }
//                } catch let error {
//                    print(error)
//                }

        
        
        
//        Alamofire.request(.GET, "https://www.fit.vutbr.cz")
//            .authenticate(user: user, password: password)
//            .response { request, response, data, error in
//
//        }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

