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
    
    func swipeTableCell(cell: MGSwipeTableCell!, didChangeSwipeState state: MGSwipeState, gestureIsActive: Bool) {
        print("cell: \(cell)")
        print("state: \(state)")
        print("gestureIsActive: \(gestureIsActive)")
    }
    
    var variants = [Variant]()
    
    struct SelectCell {
        var title:String
        var detail:String
        var when:NSDate?
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
                selectCells.append(SelectCell.init(title: object.title!, detail: "", when: object.when!))
            }
            
            print(selectCells)
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
                    selectCells.append(SelectCell.init(title: object.title!, detail: "", when: object.when!))
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
            if let sections = fetchedResultsController.sections {
                let currentSection = sections[section]
                if section == 0 {
                    return selectCells.count
                } else {
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
            
            if indexPath.section == 0 {
                cell.textLabel!.text = selectCells[indexPath.row].title
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
            
//            if !isVariant(indexPath) {
//                let removeCellButton = MGSwipeButton(title: "",
//                    icon: UIImage(named: "check.png"),
//                    backgroundColor: UIColor.greenColor()) { (sender: MGSwipeTableCell!) -> Bool in
//                        return true
//                }
//                
//                cell.leftButtons = [removeCellButton]
//                cell.leftExpansion.buttonIndex = 0
//                cell.leftExpansion.fillOnTrigger = true
//                cell.leftSwipeSettings.transition = .ClipCenter
//            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("WISLogin", forIndexPath: indexPath) as! WISLoginCell
            return cell
        }
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
    
    
    
    
    
    
    
    func isVariant(indexPath:NSIndexPath) -> Bool {
        if !expanded || indexPath.section != 0 {
            print("isVariant: !expanded || indexPath.section != 0")
            return false
        }
        if indexPath.row >= indexArray.first!.row && indexPath.row <= indexArray.last!.row {
            print("isVariant: true")
            return true
        } else {
            print("isVariant: false")
            return false
        }
    }
    
    
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("row: \(indexPath.row)")
        print("section: \(indexPath.section)")
        if loggedIn && indexPath.section == 0 {
            let cell = selectCells[indexPath.row] //fetchedResultsController.objectAtIndexPath(indexPath) as! NotificationStack
            if !expanded  {
                var i = 1
                let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                let fetchRequest = NSFetchRequest(entityName: "Task")
                fetchRequest.predicate = NSPredicate(format: "title == %@", cell.title)
                
                do {
                    let task = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Task]
                    
                    for variant in task![0].variants! {
                        print("i: \(i)")
                        variants.append(variant as! Variant)
                        selectCells.insert(SelectCell.init( title: (variant as! Variant).title!,
                            detail: "",
                            when: nil),
                            atIndex: indexPath.row + i)
                        indexArray.append(NSIndexPath(forRow: indexPath.row + i, inSection: 0))
                        i++
                    }
                    self.tableView.insertRowsAtIndexPaths(indexArray, withRowAnimation: .Top)
                    
                } catch {
                    print(error)
                }
                expanded = true
            } else {
                print("indexArray[0].row: \(indexArray[0].row)")
                print("indexArray.last!.row: \(indexArray.last!.row)")
                selectCells.removeRange(indexArray[0].row...indexArray.last!.row)
                self.tableView.deleteRowsAtIndexPaths(indexArray, withRowAnimation: .Top)
                indexArray.removeAll()
                expanded = false
            }
        }
    }
}

