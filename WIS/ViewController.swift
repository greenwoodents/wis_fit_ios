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

class ViewController:   UITableViewController,
                        UITextFieldDelegate,
                        NSFetchedResultsControllerDelegate,
                        MGSwipeTableCellDelegate {
    
    
    struct SelectCell {
        var course: String
        var title: String
        var detail: String
        var when: NSDate?
    }
    var selectCells = [SelectCell]()
    var indexArray = [NSIndexPath]()
    var expanded:Bool = false
    
    var loggedIn: Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        let tmpLoggedIn = defaults.boolForKey("loggedIn")
        return tmpLoggedIn
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let single = "single"
        let select = "select"
        let misc = "misc"
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "NotificationStack")
        let primarySortDescriptor = NSSortDescriptor(key: "type", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "course", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        let singleOrMiscPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(format: "type = %@", single),
                                                                                       NSPredicate(format: "type = %@", misc)])
        let nonRegisterPredicates = NSCompoundPredicate(andPredicateWithSubpredicates: [singleOrMiscPredicate,
                                                                                        NSPredicate(format: "when >= %@", NSDate()),
                                                                                        NSPredicate(format: "when <= %@", NSDate().dateByAddingTimeInterval(60*60*24*5))])
        
        let registerPredicates = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "type = %@", select),
                                                                                    NSPredicate(format: "when >= %@", NSDate().dateByAddingTimeInterval(60*60*24*7*(-1))),
                                                                                    NSPredicate(format: "when <= %@", NSDate().dateByAddingTimeInterval(60*60*24*2))
                                                                                    ])
        
        
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [registerPredicates, nonRegisterPredicates])
        //NSPredicate(format: "(type = %@ or type = %@) AND (when >= %@) AND (when <= %@) ", single, select, NSDate(), NSDate().dateByAddingTimeInterval(60*60*24*7))
        
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
                    self.selectCells.removeAll()
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
            
            for object in (fetchedResultsController.fetchedObjects as! [NotificationStack]) {
                if object.type! == "select" {
                    selectCells.append(SelectCell.init(course: object.course!, title: object.title!, detail: "", when: object.when!))
                }
            }
        } catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    
    
    
    
    
    
    
    
    
    
    func remoteRefresh(notification: NSNotification) {
        if loggedIn {
            do {
                try self.fetchedResultsController.performFetch()
                
                for object in (fetchedResultsController.fetchedObjects as! [NotificationStack]) {
                    if object.type! == "select" {
                        selectCells.append(SelectCell.init(course: object.course!, title: object.title!, detail: "", when: object.when!))
                    }
                }
                
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
            if self.tableView(self.tableView, titleForHeaderInSection: section) == "Registrace" {
                return selectCells.count
            } else {
                return self.fetchedResultsController.sections![section].numberOfObjects
            }
        } else {
            return 1
        }
//            if let sections = fetchedResultsController.sections {
//                let currentSection = sections[section]
//                if section == 0 {
//                    return selectCells.count
//                } else {
//                    return currentSection.numberOfObjects
//                }
//            } else {
//                return 1
//            }
//        } else {
//            return 1
//        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        formatter.dateStyle = .MediumStyle
        if loggedIn {
            let cell = tableView.dequeueReusableCellWithIdentifier("notification", forIndexPath: indexPath) as! SimpleNotificationCell
            
            if self.tableView(self.tableView, titleForHeaderInSection: indexPath.section) == "Registrace" {
                cell.course = selectCells[indexPath.row].course
                cell.mainText = selectCells[indexPath.row].title
                cell.textLabel!.text = "\(cell.course): \(cell.mainText)"
                
                if let date = selectCells[indexPath.row].when {
                    cell.detailTextLabel!.text = formatter.stringFromDate(date)
                } else {
                    cell.detailTextLabel!.text = ""
                }
                
            } else {
                let notif = fetchedResultsController.objectAtIndexPath(indexPath) as! NotificationStack
                cell.textLabel!.text = "\(notif.course!): \(notif.title!)"
                cell.detailTextLabel!.text = formatter.stringFromDate(notif.when!)
            }
            
            if !isVariant(indexPath) {
                let removeCellButton = MGSwipeButton(title: "",
                    icon: UIImage(named: "check.png"),
                    backgroundColor: UIColor.greenColor()) //{ sender -> Bool in
//                        sender.
//                        
//                        print("A")
//                        return true
//                }
                
                let postponeCellButton = MGSwipeButton(title: "Odlozit",
                    backgroundColor: UIColor.yellowColor()) //{ sender -> Bool in
//                        print("B")
//                    return true
//                }
                
                
                cell.leftButtons = [removeCellButton]
                cell.leftExpansion.buttonIndex = 0
                cell.leftExpansion.fillOnTrigger = true
                cell.leftSwipeSettings.transition = .ClipCenter
                
                cell.rightButtons = [postponeCellButton]
                cell.rightExpansion.buttonIndex = 0
                cell.rightExpansion.fillOnTrigger = true
                cell.rightSwipeSettings.transition = .ClipCenter
                
                cell.delegate = self
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("WISLogin", forIndexPath: indexPath) as! WISLoginCell
            return cell
        }
    }
    
    
    
    func isVariant(indexPath:NSIndexPath) -> Bool {
        if !expanded || indexPath.section != 0 {
            return false
        }
        if indexPath.row >= indexArray.first!.row && indexPath.row <= indexArray.last!.row {
            return true
        } else {
            return false
        }
    }
    
    
    
    
    
    
    
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if loggedIn {
            if let sections = fetchedResultsController.sections {
                let currentSection = sections[section]
                return (currentSection.name == "single" ? "Oznamy" :
                    (currentSection.name == "select") ? "Registrace" :
                    (currentSection.name == "misc") ? "Ostatné" : "")
            }
        }
        return nil
    }
    
    
    
    
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        if loggedIn && self.tableView(self.tableView, titleForHeaderInSection: indexPath.section)! == "Registrace" {
            //let cell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath) as! SimpleNotificationCell
            if !expanded  {
                var i = 1
                let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                let fetchRequest = NSFetchRequest(entityName: "Task")
                
                fetchRequest.predicate = NSPredicate(format: "title == %@", selectCells[indexPath.row].title)
                
                do {
                    let task = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Task]
                    
                    for variant in task![0].variants! {
                        
                        selectCells.insert(SelectCell.init(course: selectCells[indexPath.row].course, title: (variant as! Variant).title!,
                            detail: "",
                            when: nil),
                            atIndex: indexPath.row + i)
                        
                        indexArray.append(NSIndexPath(forRow: indexPath.row + i, inSection: indexPath.section))
                        i++
                    }
                    
                    self.tableView.insertRowsAtIndexPaths(indexArray, withRowAnimation: .Top)
                    
                } catch {
                    print(error)
                }
                expanded = true
            } else {
                selectCells.removeRange(indexArray[0].row...indexArray.last!.row)
                self.tableView.deleteRowsAtIndexPaths(indexArray, withRowAnimation: .Top)
                indexArray.removeAll()
                expanded = false
            }
        }
    }
    
    
    
    
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        if expanded {
            if indexArray.contains(self.tableView.indexPathForCell(cell)!) {
                return false
            }
        }
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        if direction == MGSwipeDirection.LeftToRight {
            
            let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            managedObjectContext.deleteObject(self.fetchedResultsController.objectAtIndexPath(self.tableView.indexPathForCell(cell)!) as! NotificationStack)
            
            do {
                try managedObjectContext.save()
                try self.fetchedResultsController.performFetch()
            } catch {
                print(error)
            }
            
            self.tableView.reloadData()//deleteRowsAtIndexPaths([self.tableView.indexPathForCell(cell)!], withRowAnimation: .Automatic)
            
            return true
        }
        return true
    }
}

