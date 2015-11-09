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
import Foundation

class ViewController: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    
    
    //var XML: Result<AnyObject>? = nil
    var managedObjectContext: NSManagedObjectContext!
    var courses = [Course]()
    var selectedIndexPath: NSIndexPath?
    var currentCell: WISLoginCell? = nil
    var displayLogin: Bool = true
    
    
    @IBOutlet var logoutButton: UIBarButtonItem!
    
    
    @IBAction func logout(sender: UIBarButtonItem) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let loggedIn = defaults.objectForKey("loggedIn") as? Bool {
            if loggedIn {
                let alert = UIAlertController(title: "Odhlásit se", message: "Chceš se opravdu odhlásit?", preferredStyle: .Alert)
                
                alert.addAction(UIAlertAction(title: "Ano", style: .Default, handler: { action in
                    defaults.setBool(false, forKey: "loggedIn")
                    defaults.setObject("", forKey: "login")
                    defaults.setObject("", forKey: "passwd")
                    self.courses.removeAll()
                    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                        NotificationManager().deleteCoreData() // TODO: nastav ako asynchronne vlakno, lebo velmi spomaluje UI
                    }
                    self.navigationItem.rightBarButtonItem = nil
                    self.displayLogin = true
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
                }))
                alert.addAction(UIAlertAction(title: "Ne", style: .Cancel, handler: { action in }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let defaults = NSUserDefaults.standardUserDefaults()

        if defaults.boolForKey("loggedIn") {
            displayLogin = false
            self.navigationItem.rightBarButtonItem = logoutButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Course")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            courses = results as! [Course]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteRefresh:", name: "remoteRefreshID", object: nil)
        
        
        
        
    }
    
    func remoteRefresh(notification: NSNotification) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        displayLogin = false
        
        let fetchRequest = NSFetchRequest(entityName: "Course")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            courses = results as! [Course]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        self.navigationItem.rightBarButtonItem = logoutButton
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    
    
    // MARK: Tableview controller methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if displayLogin {
            return 1;
        } else {
            return courses.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if displayLogin {
            let cell = tableView.dequeueReusableCellWithIdentifier("WISLogin", forIndexPath: indexPath) as! WISLoginCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("test", forIndexPath: indexPath) as! PointsCell
            cell.pointsForCourse.text = courses[indexPath.row].title_cs
            return cell
        }
    }
    
    
    // MARK: Cell expansion
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let previousIndexPath = selectedIndexPath
        
        currentCell = tableView.cellForRowAtIndexPath(indexPath) as? WISLoginCell
        
        if indexPath == previousIndexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
        }
        
        var indexPaths = [NSIndexPath]()
        
        if let previous = previousIndexPath {
            indexPaths += [previous]
        }
        
        if let current = selectedIndexPath {
            indexPaths += [current]
        }
        
        if indexPaths.count > 0 {
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if displayLogin {
            if let c = cell as? WISLoginCell {
                c.ignoreFrameChanges()
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if displayLogin {
            if let c = cell as? WISLoginCell {
                c.ignoreFrameChanges()
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath == selectedIndexPath {
            return WISLoginCell.expandedHeight
        } else {
            return WISLoginCell.defaultHeight
        }
    }
    
    
}

