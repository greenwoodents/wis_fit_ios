//
//  MailBodyCell.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 18.02.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit

class MailBodyCell: UITableViewCell, UIWebViewDelegate {

    var emailKit: (MCOIMAPSession, MCOIMAPMessage)?
    
    
    @IBOutlet var acitvityIndicator: UIActivityIndicatorView!
    @IBOutlet var webView: UIWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        acitvityIndicator.hidesWhenStopped = true
        acitvityIndicator.startAnimating()
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.dataDetectorTypes = .All
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadContent() {
        loadEmailBody(emailKit!.0, email: emailKit!.1, folder: "inbox") { htmlBody in
            self.webView.loadHTMLString(htmlBody, baseURL: nil)
            self.acitvityIndicator.stopAnimating()
        }
    }
    
    func loadEmailBody(session: MCOIMAPSession, email: MCOIMAPMessage, folder: String, callback: (String)->()) {
        let operation: MCOIMAPFetchContentOperation = session.fetchMessageOperationWithFolder(folder, uid: email.uid)
        
        operation.start { error, data -> Void in
            let messageParser: MCOMessageParser = MCOMessageParser(data: data)
            let message = messageParser.htmlBodyRendering()
            callback(message)
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked {
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }

}
