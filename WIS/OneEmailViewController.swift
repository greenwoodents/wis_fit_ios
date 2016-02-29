//
//  OneEmailViewController.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 18.02.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit

class OneEmailViewController: UITableViewController {
    
    var emailKit: (MCOIMAPSession, MCOIMAPMessage)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController
        self.navigationController!.navigationBar.subviews[1].hidden = !self.navigationController!.navigationBar.subviews[1].hidden
        self.navigationController!.interactivePopGestureRecognizer!.enabled = false
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch(indexPath.row) {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell", forIndexPath: indexPath)
            if let displayName = emailKit?.1.header.from.displayName {
                cell.textLabel!.text = "From: \(displayName)"
            } else if let mailbox = emailKit?.1.header.from.mailbox {
                cell.textLabel!.text = "From: \(mailbox)"
            }
            
            let receivers: String = ""
//            for receiver in emailKit!.1.header.to as! [MCOAddress] {
//                receivers = receivers + receiver.displayName + " "
//            }
            cell.detailTextLabel!.text = "To: \(receivers)"
            return cell
        case 1:
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let cell = tableView.dequeueReusableCellWithIdentifier("SubjectCell", forIndexPath: indexPath)
            cell.textLabel!.text = emailKit?.1.header.subject ?? ""
            if let date = emailKit?.1.header.date {
                cell.detailTextLabel!.text = dateFormatter.stringFromDate(date)
            } else {
                cell.detailTextLabel!.text = ""
            }
            return cell
        default:
            let mailBodyCell = tableView.dequeueReusableCellWithIdentifier("BodyCell", forIndexPath: indexPath) as! MailBodyCell
            mailBodyCell.autoresizingMask = .FlexibleBottomMargin
            mailBodyCell.emailKit = self.emailKit!
            mailBodyCell.loadContent()
            return mailBodyCell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 2 {
            let y = self.view.frame.height - 2*54
            return CGFloat(y)
        } else {
            return CGFloat(54)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    

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

}
