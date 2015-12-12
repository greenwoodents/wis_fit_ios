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
import MGSwipeTableCell

class ViewController: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    var selectedIndexPath: NSIndexPath?
    var variants = [Variant]()
    var currentCell: WISLoginCell? = nil
    var loggedIn: Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let tmpLoggedIn = defaults.boolForKey("loggedIn")
        return tmpLoggedIn
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let single = "single"
        let select = "select"
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "NotificationStack")
        let primarySortDescriptor = NSSortDescriptor(key: "type", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "course", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "(type = %@ or type = %@) AND (when >= %@) AND (when <= %@) ", single, select, NSDate(), NSDate().dateByAddingTimeInterval(60*60*24*7))
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: managedContext,
            sectionNameKeyPath: "type",
            cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
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
                    defaults.synchronize()
                    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                        NotificationManager().deleteCoreData()
                    }
                    self.navigationItem.rightBarButtonItem = nil
                    
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Ne", style: .Cancel, handler: { action in }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.tableFooterView = UIView.init(frame: CGRectZero)

        if loggedIn {
            self.navigationItem.rightBarButtonItem = logoutButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteRefresh:", name: "remoteRefreshID", object: nil)
        if loggedIn {
            self.refreshControl = UIRefreshControl()
            self.refreshControl!.addTarget(self, action: "remoteRefresh:", forControlEvents: UIControlEvents.ValueChanged)
            self.tableView.addSubview(refreshControl!)
        }
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        let bgImageView = UIImageView(image: UIImage(named: "fit11.png")!)
        self.view.superview!.insertSubview(bgImageView, belowSubview: self.view)
    }
    
    func remoteRefresh(notification: NSNotification) {
        if loggedIn {
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                print(error)
            }
            self.navigationItem.rightBarButtonItem = logoutButton
            self.tableView.reloadData()
        }
    }
    
    // MARK: Tableview controller methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if loggedIn {
            if let sections = fetchedResultsController.sections {
                return sections.count
            }
        }
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loggedIn {
            if let sections = fetchedResultsController.sections {
                let currentSection = sections[section]
                if section == 0 {
                    print("variants count: \(variants.count)")
                    
                    return currentSection.numberOfObjects + variants.count
                } else {
                    print("SECTION = 1")
                    return currentSection.numberOfObjects
                }
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        formatter.dateStyle = .MediumStyle
        if loggedIn {
            let cell = tableView.dequeueReusableCellWithIdentifier("notification", forIndexPath: indexPath) as! SimpleNotificationCell
            let notif = fetchedResultsController.objectAtIndexPath(indexPath) as! NotificationStack
            cell.textLabel!.text = "\(notif.course!): \(notif.title!)"
            
            cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named: "check.png"), backgroundColor: UIColor.greenColor())]
            cell.leftExpansion.buttonIndex = 0
            cell.leftExpansion.fillOnTrigger = true
            cell.leftSwipeSettings.transition = .ClipCenter
            
//            cell.detailTextLabel!.text = formatter.stringFromDate(notif.when!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("WISLogin", forIndexPath: indexPath) as! WISLoginCell
            return cell
        }
//        if loggedIn {
//            
//            
//            
//            
//
//            if let type = notifs[indexPath.row].type {
//                if type == "select" {
//                    let cell = tableView.dequeueReusableCellWithIdentifier("select_notification", forIndexPath: indexPath) as! SelectNotificationCell
//                    cell.title!.text = "\(notifs[indexPath.row].course!): \(notifs[indexPath.row].title!)"
//                    cell.detail!.text = formatter.stringFromDate(notifs[indexPath.row].when!)
//                    return cell
//                    
//                    
//                } else {
//                    let cell = tableView.dequeueReusableCellWithIdentifier("notification", forIndexPath: indexPath) as! SimpleNotificationCell
//                    cell.textLabel!.text = "\(notifs[indexPath.row].course!): \(notifs[indexPath.row].title!)"
//                    cell.detailTextLabel!.text = formatter.stringFromDate(notifs[indexPath.row].when!)
//                    
//                    cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named: "check.png"), backgroundColor: UIColor.greenColor())]
//                    cell.leftExpansion.buttonIndex = 0
//                    cell.leftExpansion.fillOnTrigger = true
//                    cell.leftExpansion.threshold = 3
//                    cell.leftSwipeSettings.transition = .ClipCenter
//                    
//                    cell.rightButtons = [MGSwipeButton(title: "Odložit", backgroundColor: UIColor.orangeColor())]
//                    cell.rightSwipeSettings.transition = .ClipCenter
//                    return cell
//                }
//            } else {
//                let cell = tableView.dequeueReusableCellWithIdentifier("notification", forIndexPath: indexPath) as! SimpleNotificationCell
//                cell.textLabel!.text = "\(notifs[indexPath.row].course!): \(notifs[indexPath.row].title!)"
//                cell.detailTextLabel!.text = formatter.stringFromDate(notifs[indexPath.row].when!)
//                
//                cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named: "check.png"), backgroundColor: UIColor.greenColor())]
//                cell.leftExpansion.buttonIndex = 0
//                cell.leftExpansion.fillOnTrigger = true
//                cell.leftExpansion.threshold = 3
//                cell.leftSwipeSettings.transition = .ClipCenter
//                
//                cell.rightButtons = [MGSwipeButton(title: "Odložit", backgroundColor: UIColor.orangeColor())]
//                cell.rightSwipeSettings.transition = .ClipCenter
//                return cell
//            }
//        } else {
//            let cell = tableView.dequeueReusableCellWithIdentifier("WISLogin", forIndexPath: indexPath) as! WISLoginCell
//            return cell
//        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if loggedIn {
            if let sections = fetchedResultsController.sections {
                let currentSection = sections[section]
                return (currentSection.name == "single" ? "Oznamy" :
                    (currentSection.name == "select") ? "Registace" :
                    "")
            }
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if loggedIn {
            let cell = fetchedResultsController.objectAtIndexPath(indexPath) as! NotificationStack
            if cell.type == "select" {
                var indexArray = [NSIndexPath]()
                var i = 1
                let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                let fetchRequest = NSFetchRequest(entityName: "Task")
                fetchRequest.predicate = NSPredicate(format: "title == %@", cell.title!)
                
                do {
                    let task = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Task]
                    
                    for variant in task![0].variants! {
                        variants.append(variant as! Variant)
                        indexArray.append(NSIndexPath(forRow: indexPath.row + i, inSection: 0))
                        i++
                    }
                    self.tableView.insertRowsAtIndexPaths(indexArray, withRowAnimation: .Automatic)
                    
                    
                } catch {
                    print(error)
                }
                
                
                
                
                
            }

        }
        
    }
}

