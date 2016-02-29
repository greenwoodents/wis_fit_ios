//
//  MailViewController.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 12.02.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit


class MailViewController: UITableViewController {

    var session: MCOIMAPSession
    var emails: [MCOIMAPMessage]
    var previouslySelectedCell: NSIndexPath?
    var selectedCell: NSIndexPath?
    var currentEmail: MCOIMAPMessage?
    var lastCellRow: Int {
        return emails.count
    }
    
    var loggedIn: Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let tmpLoggedIn = defaults.boolForKey("loggedIn")
        return tmpLoggedIn
    }
    
    required init(coder aDecoder: NSCoder) {
        self.session = MCOIMAPSession()
        self.emails = [MCOIMAPMessage]()
        super.init(coder: aDecoder)!
        
        downloadInbox()
    }
    
    func downloadInbox() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if loggedIn {
            session.hostname = "eva.fit.vutbr.cz"
            session.port = 993
            session.username = defaults.stringForKey("login")!
            session.password = defaults.stringForKey("passwd")!
            session.connectionType = .TLS
            session.checkCertificateEnabled = false
            
            let requestKind = MCOIMAPMessagesRequestKind.Headers
            let folder = "inbox"
            let uids = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
            let fetchOperation = session.fetchMessagesOperationWithFolder(folder, requestKind: requestKind, uids: uids)
            
            fetchOperation.start { (error, fetchedMessages, vanishedMessages) -> Void in
                if error != nil {
                    print(error)
                } else {
                    self.emails.removeAll()
                    self.emails = (fetchedMessages as! [MCOIMAPMessage]).reverse()
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.subviews[1].hidden = false
//        self.navigationController!.navigationBar.subviews[1].subviews[1].hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if emails.isEmpty {
            downloadInbox()
        }
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("IsNotFirstLaunch") {
            let folder = "inbox"
            let uids = MCOIndexSet(range: MCORangeMake(1, UINT64_MAX))
            
            let operation = session.storeFlagsOperationWithFolder(folder, uids: uids, kind: MCOIMAPStoreFlagsRequestKind.Add, flags: MCOMessageFlag.Seen)
            
            operation.start { error in
                if error != nil {
                    print(error)
                } else {
                    print("Should be changed")
                }
            }
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "IsNotFirstLaunch")
        }
        self.refreshControl!.addTarget(self, action: "handleRefresh:", forControlEvents: .ValueChanged)
        self.tableView.allowsMultipleSelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if loggedIn {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loggedIn {
            return emails.count + 1
        } else {
            return 0
        }
    }
    
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row != lastCellRow {
            let cell = tableView.dequeueReusableCellWithIdentifier("mailCellIdentifier", forIndexPath: indexPath)
            let email = emails[indexPath.row]
            cell.textLabel!.text = email.header.from.displayName ?? email.header.from.mailbox
            cell.detailTextLabel!.text = email.header.subject
            return cell
        } else if !emails.isEmpty {
            let lastCell = tableView.dequeueReusableCellWithIdentifier("lastCell", forIndexPath: indexPath) as UITableViewCell
            lastCell.textLabel!.text = "From Ents & Tomáš Ščavnický"
            lastCell.detailTextLabel!.text = "\nfor fiťáci 💛"
            lastCell.userInteractionEnabled = false
            return lastCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("mailCellIdentifier", forIndexPath: indexPath)
            cell.textLabel!.text = ""
            cell.detailTextLabel!.text = ""
            return cell
        }
    }

    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedCell = indexPath
        currentEmail = emails[indexPath.row]
        self.performSegueWithIdentifier("mailContentSegue", sender: self)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let email = emails[indexPath.row]
            let uids = MCOIndexSet(index: UInt64(email.uid))
            let folder = "inbox"
            let op = session.storeFlagsOperationWithFolder(folder, uids: uids, kind: .Set, flags: .Deleted)
            
            op.start { error in
                if error != nil {
                    print(error)
                } else {
                    let deleteOp = self.session.expungeOperation(folder)
                    deleteOp.start { error in
                        if error != nil {
                            print(error)
                        } else {
                            self.emails.removeAtIndex(indexPath.row)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String {
        return "Vymazať"
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if loggedIn {
            downloadInbox()
        }
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
////        if selectedCell != nil && previouslySelectedCell == nil && selectedCell?.row == indexPath.row && selectedCell != previouslySelectedCell {
////            return CGFloat(100)
////        }
////        if selectedCell != nil && previouslySelectedCell != nil && selectedCell?.row == indexPath.row && selectedCell == previouslySelectedCell {
////            return CGFloat(44)
////        }
////        if selectedCell != nil && previouslySelectedCell != nil && selectedCell?.row == indexPath.row && selectedCell != previouslySelectedCell {
////            return CGFloat(100)
////        }
////        return CGFloat(44)
//        return UITableViewAutomaticDimension
//    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mailContentSegue" {
            let vc = segue.destinationViewController as! OneEmailViewController
            if currentEmail != nil {
                vc.emailKit = (session, currentEmail!)
            }
            
        }
    }

}
