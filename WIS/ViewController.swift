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
    var courses = [NSManagedObject]()
    var selectedIndexPath: NSIndexPath?
    var currentCell: WISLoginCell? = nil
    
    
    func fetchResults() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Course")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            courses = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    @IBAction func logout(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let loggedIn = defaults.objectForKey("loggedIn") as? Bool {
            if loggedIn {
                let alert = UIAlertController(title: "Odhlásit se", message: "Chceš se opravdu odhlásit?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ano", style: UIAlertActionStyle.Default, handler: { action in
                    switch action.style {
                    case .Default:
                        defaults.setBool(false, forKey: "loggedIn")
                        defaults.setObject("", forKey: "login")
                        defaults.setObject("", forKey: "passwd")
                        break
                    case .Cancel:
                        print("cancel")
                        break
                    default:
                        print("default")
                        break
                    }
                }))
                alert.addAction(UIAlertAction(title: "Ne", style: UIAlertActionStyle.Cancel, handler: { action in
                    switch action.style {
                    case .Default:
                        defaults.setBool(false, forKey: "loggedIn")
                        defaults.setObject("", forKey: "login")
                        defaults.setObject("", forKey: "passwd")
                        break
                    case .Cancel:
                        print("cancel")
                        break
                    default:
                        print("default")
                        break
                    }
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Nejsi přihlásen", message: "", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Přihlásit se", style: .Default, handler: { action in
                    print("expand cell and select login textfield")
                }))
                alert.addAction(UIAlertAction(title: "Zrušit", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteRefresh:", name: "remoteRefreshID", object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func remoteRefresh(notification: NSNotification) {
        fetchResults()
        self.tableView.reloadData()
    }
    
    
    // MARK: Save course
    
    
    func save_course(id: String, abbreviation abbrv: String, cesky title_cs: String, english title_en: String, semester sem: String, credits: String, points: String)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("Course", inManagedObjectContext:managedContext)
        let course = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext)

        
        //3
        course.setValue(abbrv, forKey: "abbrv")
        course.setValue(NSNumber(integer: Int(credits  as String)!), forKey: "credits")
        course.setValue(NSNumber(integer: Int(id as String)!), forKey: "id")
        course.setValue(NSNumber(integer: Int(points as String)!), forKey: "points")
        course.setValue(sem, forKey: "sem")
        course.setValue(title_cs, forKey: "title_cs")
        course.setValue(title_en, forKey: "title_en")
        
        //4
        do {
            try managedContext.save()
            //5
            courses.append(course)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: Tableview controller methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + courses.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("WISLogin", forIndexPath: indexPath) as! WISLoginCell
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("test", forIndexPath: indexPath) as! PointsCell
            cell.pointsForCourse.text = "ahoj"
            return cell
        } else if indexPath.row > 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("test", forIndexPath: indexPath) as! PointsCell
            let course = courses[indexPath.row - 2]
            cell.pointsForCourse.text = "\(course.valueForKey("abbrv")!) - \(course.valueForKey("points")!)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("WISLogin", forIndexPath: indexPath) as! WISLoginCell
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
        if indexPath.row == 0 {
            (cell as! WISLoginCell).watchFrameChanges()
        }
        
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            (cell as! WISLoginCell).ignoreFrameChanges()
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

