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



class ViewController:   UITableViewController, UITextFieldDelegate, MGSwipeTableCellDelegate {
    
    var dataFetchController: DataFetcher
    var expandableCells = [SelectCell]()
    var selectedIndexPath : NSIndexPath?
    var selectedCellForPostponeIndexPath: NSIndexPath?
    
    // Array of variant cell indexes
    var indexArray = [NSIndexPath]()
    var currentCellIndexPath: NSIndexPath? = nil
    var expanded:Bool  {
        return !indexArray.isEmpty
    }
    var menzaCellExpanded: Bool = false
    var isLunchTime: Bool {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour], fromDate: date)
        let hour = components.hour
        return (hour > 9 && hour < 14)
    }
    private func todayMenu(callback: (menu: String)->Void) {
        var menu = ""
        Alamofire.request(.GET, "http://www.kam.vutbr.cz/?p=menu&provoz=5")
        .responseString { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    for match in matchesForRegexInText("b>.*<small", text: value) {
                        let newString = match.stringByReplacingOccurrencesOfString("b>", withString: "")
                        menu = menu + "\n" + newString.stringByReplacingOccurrencesOfString("<small", withString: "")
                    }
                }
            case .Failure(let error):
                print(__LINE__)
                print(__FUNCTION__)
                print(error)
            }
            callback(menu: menu)
        }
    }
    
    override init(style: UITableViewStyle) {
        dataFetchController = DataFetcher()
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        dataFetchController = DataFetcher()
        super.init(coder: aDecoder)
    }
    
    
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
                    defaults.setValue(nil, forKey: "class")
                    defaults.synchronize()
                    dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                        NotificationManager().deleteCoreData()
                    }
                    self.expandableCells.removeAll()
                    self.navigationItem.rightBarButtonItem = nil
                    
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Ne", style: .Cancel, handler: { action in }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {        
        if loggedIn {
            self.navigationItem.rightBarButtonItem = logoutButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
//        self.navigationController!.navigationBar.subviews[1].subviews[1].hidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        for cell in tableView.visibleCells {
            let menzaCell = cell as? MenzaCell
            if menzaCell != nil {
                menzaCell!.ignoreFrameChanges()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataFetchController = DataFetcher()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "remoteRefresh:", name: "fillMostRecentNotifsID", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "postponeViewDismissed:", name: "postponeViewDismissedID", object: nil)
        
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        if loggedIn {
            self.refreshControl!.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        }
        
        self.dataFetchController.performFetch{
            for object in self.dataFetchController.fetchedObjects {
                
                if object.type! == "select" {
                    self.expandableCells.append(SelectCell.init(course: object.course!, title: object.title!, detail: "", what: object.what ?? "", when: object.when!))
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        if loggedIn {
            dataFetchController.performFetch {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            
            if isLunchTime {
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                    let menza = "menza"
                    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                    let fetchRequest = NSFetchRequest(entityName: "NotificationStack")
                    fetchRequest.predicate = NSPredicate(format: "type = %@", menza)
                    do {
                        var menzas = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NotificationStack]
                        switch (menzas.count) {
                        case 0:
                            self.todayMenu() { menu in
                                if menu.isEmpty { return }
                                let menzaNotif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedObjectContext) as! NotificationStack
                                
                                menzaNotif.title = menu
                                menzaNotif.course = "MNZ"
                                menzaNotif.type = menza
                                
                                do {
                                    try managedObjectContext.save()
                                } catch {
                                    print(error)
                                }
                            }
                            break
                        case 1:
                            self.todayMenu() { menu in
                                if menu.isEmpty { return }
                                menzas.first?.title = menu
                            }
                        default:
                            menzas.removeAll()
                            do {
                                try managedObjectContext.save()
                            } catch {
                                print(error)
                            }
                            break
                        }
                    } catch {
                        print(error)
                    }
                    
                    
                    self.dataFetchController.performFetch {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    
    
    
    
    func remoteRefresh(notification: NSNotification) {
        if loggedIn {
            self.tableView.alwaysBounceVertical = true
            dataFetchController.performFetch {
                for object in self.dataFetchController.fetchedObjects {
                    if object.type! == "select" {
                        self.expandableCells.append(SelectCell.init(course: object.course!, title: object.title!, detail: "", what: object.what ?? "", when: object.when!))
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func registerNotification(title: String, when: NSDate) {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        if settings.types == .None {
            let ac = UIAlertController(title: "Nemám povolenie zobraziť notifikácie", message: "", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        let emojiArray = ["🕐","🕑","🕒","🕓","🕔","🕕","🕖","🕗","🕘","🕙","🕚","🕛","🕜","🕝","🕞","🕟","🕠","🕡","🕢","🕣","🕤","🕥","🕦","🕧"]
        let emoji = emojiArray[Int(arc4random_uniform(UInt32(emojiArray.count)))]
        let notification = UILocalNotification()
        notification.alertBody = "\(emoji) \(title)"
        notification.alertAction = "open."
        notification.fireDate = when.addHours(-1)
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = nil
        print(notification.fireDate)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    
    func postponeViewDismissed(notification: NSNotification) {
        if loggedIn {
            
            let userInfo = notification.userInfo as! [String:Int]
            switch (userInfo["postponeType"]!) {
            case 0:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: userInfo["row"]!, inSection: userInfo["section"]!)) as! MGSwipeTableCell
                cell.hideSwipeAnimated(true)
                break
            case 1:
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: userInfo["row"]!, inSection: userInfo["section"]!)) as! MGSwipeTableCell
                let indexPath = NSIndexPath(forRow: userInfo["row"]!, inSection: userInfo["section"]!)
                let cellData = dataFetchController.objectAtIndexPath(indexPath)
                let numberOfRowsInSection = tableView(self.tableView, numberOfRowsInSection: indexPath.section)
                let titleForSection = self.tableView(self.tableView, titleForHeaderInSection: indexPath.section)!
                let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                let entityDescription = NSEntityDescription.entityForName("NotificationStack", inManagedObjectContext: managedObjectContext)!
                let fetchRequest = NSFetchRequest()
                let newNotificationTime: NSDate = NSDate().localTime(NSDate().addMinutes(1))
                
                fetchRequest.entity = entityDescription
                fetchRequest.predicate = NSPredicate(format: "SELF = %@", cellData)
                
                do {
                    let o = try managedObjectContext.executeFetchRequest(fetchRequest).first! as! NotificationStack
                    o.whenNotify = newNotificationTime
                    try managedObjectContext.save()
                } catch {
                    print(__LINE__)
                    print(__FUNCTION__)
                    print(error)
                }
                
                
                dataFetchController.performFetch  {
                    self.expandableCells.removeAll()
                    
                    for object in self.dataFetchController.fetchedObjects {
                        if object.type! == "select" {
                            self.expandableCells.append(SelectCell.init(course: object.course!, title: object.title!, detail: "", what: object.what ?? "", when: object.when!))
                        }
                    }
                    self.registerNotification(cellData.title!, when: newNotificationTime)
                    self.removeRows(indexPath, titleForSection: titleForSection, numberOfRowsInSection: numberOfRowsInSection, cell: cell)
                    cell.hideSwipeAnimated(true)
                }
                break
                
            default: break
            }
        }
    }
    
    
    
    
    // MARK: Tableview Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if loggedIn {
            return dataFetchController.sections.count
        }
        return 1;
    }
    
    
    
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loggedIn {
            if self.tableView(self.tableView, titleForHeaderInSection: section) == "Registrace" {
                return expandableCells.count
            }  else {
                if dataFetchController.sections.count > section {
                    return dataFetchController.sections[section].count
                } else {
                    return 0
                }

            }
        } else {
            return 1 // wis login cell
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .MediumStyle
        if loggedIn {
            func setSwipeButtons(inout thisCell: GraphicalNotificationCell) {
                if !isVariant(indexPath) {
                    
                    
                    let removeCellButton = MGSwipeButton(title: "\(String.fontAwesomeIconWithName(FontAwesome.Check))        ", backgroundColor: UIColor(red: CGFloat(120.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(86.0/255.0), alpha: 1))
                    
                    removeCellButton.titleLabel!.font = UIFont.fontAwesomeOfSize(45)
                    removeCellButton.titleLabel!.sizeToFit()
                    
                    let postponeCellButton = MGSwipeButton(title: "\(String.fontAwesomeIconWithName(FontAwesome.ClockO))            ",
                        backgroundColor: UIColor(red: CGFloat(255.0/255.0), green: CGFloat(220.0/255.0), blue: CGFloat(76.0/255.0), alpha: 1))
                    postponeCellButton.titleLabel!.font = UIFont.fontAwesomeOfSize(45)
                    postponeCellButton.titleLabel!.sizeToFit()
                    
                    thisCell.leftButtons = [removeCellButton]
                    thisCell.leftExpansion.buttonIndex = 0
                    thisCell.leftExpansion.fillOnTrigger = true
                    thisCell.leftSwipeSettings.transition = .ClipCenter
                    
                    thisCell.rightButtons = [postponeCellButton]
                    thisCell.rightExpansion.buttonIndex = 0
                    thisCell.rightExpansion.fillOnTrigger = true
                    thisCell.rightSwipeSettings.transition = .ClipCenter
                    
                    thisCell.delegate = self
                }
            }
            
            switch (self.tableView(self.tableView, titleForHeaderInSection: indexPath.section)!) {
            case "Oznamy":
                var cell = tableView.dequeueReusableCellWithIdentifier("graphical", forIndexPath: indexPath) as! GraphicalNotificationCell
                let notif = dataFetchController.objectAtIndexPath(indexPath)
                cell.primaryTextLabel!.text = notif.title ?? ""
                if let when = notif.when {
                    let prefix = notif.what != nil ? notif.what! + ": " : ""
                    cell.secondaryTextLabel!.text = prefix + formatter.stringFromDate(when)
                }
                cell.course = notif.course ?? ""
                cell.redraw()
                setSwipeButtons(&cell)
                return cell
            case "Menza":
                let cell = tableView.dequeueReusableCellWithIdentifier("menza", forIndexPath: indexPath) as! MenzaCell
                let notif = dataFetchController.objectAtIndexPath(indexPath)
                cell.menu.text = notif.title
                return cell
            default:
                var cell = tableView.dequeueReusableCellWithIdentifier("graphical", forIndexPath: indexPath) as! GraphicalNotificationCell
                cell.course = expandableCells[indexPath.row].course
                cell.redraw()
                cell.mainText = expandableCells[indexPath.row].title
                cell.primaryTextLabel!.text = cell.mainText
                
                if let date = expandableCells[indexPath.row].when {
                    cell.secondaryTextLabel!.text = expandableCells[indexPath.row].what! + ": " + formatter.stringFromDate(date)
                } else {
                    cell.secondaryTextLabel!.text = ""
                }
                setSwipeButtons(&cell)
                
                
                
//                if isVariant(indexPath) {
//                    cell.contentView.backgroundColor = createColor(expandableCells[indexPath.row].course, light: true)
//                    cell.redrawWithColorBackground()
//                } else {
//                    cell.contentView.backgroundColor = UIColor.whiteColor()
//                }
                
                return cell
            }
        } else {
            self.tableView.alwaysBounceVertical = false
            let cell = tableView.dequeueReusableCellWithIdentifier("WISLogin", forIndexPath: indexPath) as! WISLoginCell
            return cell
        }
    }
    
    
    
    private func isVariant(indexPath:NSIndexPath) -> Bool {
        if indexArray.contains(indexPath) && expanded {
            return true
        } else {
            return false
        }
    }
    
    
    
    
    
    
    
    
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if loggedIn {
            if dataFetchController.sections.count > section {
                if let currentSectionName = dataFetchController.sections[section].first!.type {
                    return (currentSectionName == "single" ? "Oznamy" :
                        (currentSectionName == "select") ? "Registrace" :
                        (currentSectionName == "misc") ? "Ostatné" :
                        (currentSectionName == "menza") ? "Menza" : "")
                } else {
                    return nil
                }
            }
        }
        return nil
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        func takeScreenshot() -> UIImage{
            
            let layer = UIApplication.sharedApplication().keyWindow?.layer
            let scale = UIScreen.mainScreen().scale
            UIGraphicsBeginImageContextWithOptions(layer!.frame.size, false, scale);
            
            layer!.renderInContext(UIGraphicsGetCurrentContext()!)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return screenshot
        }
        
        
        if segue.identifier! == "postponeSegue" && !isVariant(currentCellIndexPath!) {
            
            let a = segue.destinationViewController as! PostponeViewController
            

            
            
            
            a.currentIndexPath = currentCellIndexPath
            a.abc = "Hello world!"
        }
        currentCellIndexPath = nil
    }
    
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let menzaCell = cell as? MenzaCell
        if menzaCell != nil {
            menzaCell!.watchFrameChanges()
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell is MenzaCell {
            (cell as! MenzaCell).ignoreFrameChanges()
        }
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if loggedIn  {
            let menzaCell = tableView.cellForRowAtIndexPath(indexPath) as? MenzaCell
            if menzaCell != nil {
                let previousIndexPath = selectedIndexPath
                if indexPath == selectedIndexPath {
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
            } else {
                switch(self.tableView(self.tableView, titleForHeaderInSection: indexPath.section)!) {
                case "Registrace":
                    if !expanded  {
                        var i = 1
                        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                        let fetchRequest = NSFetchRequest(entityName: "Task")
                        
                        fetchRequest.predicate = NSPredicate(format: "title == %@", expandableCells[indexPath.row].title)
                        
                        
                        do {
                            let task = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Task]
                            var tmpArray = [SelectCell]()
                            for variant in task![0].variants! {
                                
                                tmpArray.append(SelectCell.init(course: expandableCells[indexPath.row].course, title: (variant as! Variant).title!,
                                    detail: "",
                                    what: "",
                                    when: nil))
                                indexArray.append(NSIndexPath(forRow: indexPath.row + i, inSection: indexPath.section))
                                i++
                            }
                            tmpArray.sortInPlace {$0.title < $1.title}
                            expandableCells.insertContentsOf(tmpArray, at: indexPath.row + 1)
                            
                            tableView.beginUpdates()
                            self.tableView.insertRowsAtIndexPaths(indexArray, withRowAnimation: .Automatic)
                            tableView.endUpdates()
                        } catch {
                            print(__LINE__)
                            print(__FUNCTION__)
                            print(error)
                        }
                    } else {
                        expandableCells.removeRange(indexArray.first!.row...indexArray.last!.row)
                        tableView.beginUpdates()
                        self.tableView.deleteRowsAtIndexPaths(indexArray, withRowAnimation: .Automatic)
                        indexArray.removeAll()
                        tableView.endUpdates()
                    }
                    
                    break
                case "Menza":
                    menzaCellExpanded = menzaCellExpanded ? false : true
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    break
                default: break
                }
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let menzaCell = tableView.cellForRowAtIndexPath(indexPath) as? MenzaCell
//        if menzaCell != nil {
//            if indexPath == selectedIndexPath {
//                return MenzaCell.expandedHeight
//            } else {
//                return MenzaCell.defaultHeight
//            }
//        }
//        return tableView.cellForRowAtIndexPath(indexPath)!.frame.height
//    }
    
    
    
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
            
            let indexPath = self.tableView.indexPathForCell(cell)!
            let numberOfRowsInSection = tableView(self.tableView, numberOfRowsInSection: indexPath.section)
            let titleForSection = self.tableView(self.tableView, titleForHeaderInSection: indexPath.section)!
            
            let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            
            if expanded {
                expandableCells.removeRange((indexArray.first!.row - 1)...indexArray.last!.row) // .row - 1 because you want to remove parent cell which is above the variant cells
            }
            managedObjectContext.deleteObject(dataFetchController.objectAtIndexPath(indexPath))
            
            
            do {
                try managedObjectContext.save()
                dataFetchController.performFetch {
                self.expandableCells.removeAll()
                    for object in self.dataFetchController.fetchedObjects {
                        if object.type! == "select" {
                            self.expandableCells.append(SelectCell.init(course: object.course!, title: object.title!, detail: "", what: object.what ?? "", when: object.when!))
                        }
                    }
                }
            } catch {
                print(__LINE__)
                print(__FUNCTION__)
                print(error)
            }
            
            removeRows(indexPath, titleForSection: titleForSection, numberOfRowsInSection: numberOfRowsInSection, cell: cell)
            
            return false
        } else if direction == MGSwipeDirection.RightToLeft {
            let ac = UIAlertController(title: "Pripomenúť", message: "", preferredStyle: .ActionSheet)
            let indexPath = self.tableView.indexPathForCell(cell)!
            let cellData = self.dataFetchController.objectAtIndexPath(indexPath)
            let numberOfRowsInSection = self.tableView(self.tableView, numberOfRowsInSection: indexPath.section)
            let titleForSection = self.tableView(self.tableView, titleForHeaderInSection: indexPath.section)!
            let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let entityDescription = NSEntityDescription.entityForName("NotificationStack", inManagedObjectContext: managedObjectContext)!
            let fetchRequest = NSFetchRequest()
            
            ac.addAction(UIAlertAction(title: "Za hodinu", style: UIAlertActionStyle.Default) { action in
                fetchRequest.entity = entityDescription
                fetchRequest.predicate = NSPredicate(format: "SELF = %@", cellData)
                
                let newNotificationTime = NSDate().localTime(NSDate().addHours(1))
                if cellData.when!.isGreaterThanDate(newNotificationTime) {
                    do {
                        let o = try managedObjectContext.executeFetchRequest(fetchRequest).first! as! NotificationStack
                        o.whenNotify = newNotificationTime
                        try managedObjectContext.save()
                    } catch {
                        print(__LINE__)
                        print(__FUNCTION__)
                        print(error)
                    }
                }
                
                self.dataFetchController.performFetch  {
                    self.expandableCells.removeAll()
                    
                    for object in self.dataFetchController.fetchedObjects {
                        if object.type! == "select" {
                            self.expandableCells.append(SelectCell.init(course: object.course!, title: object.title!, detail: "", what: object.what ?? "", when: object.when!))
                        }
                    }
                    let notificationMessage = "\(cellData.course!): \(cellData.title!)"
                    self.registerNotification(notificationMessage, when: newNotificationTime)
                    if cellData.when!.isGreaterThanDate(NSDate().localTime(NSDate().addHours(1))) {
                        self.removeRows(indexPath, titleForSection: titleForSection, numberOfRowsInSection: numberOfRowsInSection, cell: cell)
                    }
                    cell.hideSwipeAnimated(true)
                }
            })
            
            ac.addAction(UIAlertAction(title: "Zajtra o tomto čase", style: UIAlertActionStyle.Default) { action in
                fetchRequest.entity = entityDescription
                fetchRequest.predicate = NSPredicate(format: "SELF = %@", cellData)
                
                let newNotificationTime = NSDate().localTime(NSDate().addDays(1))
                if cellData.when!.isGreaterThanDate(newNotificationTime) {
                    do {
                        let o = try managedObjectContext.executeFetchRequest(fetchRequest).first! as! NotificationStack
                        o.whenNotify = newNotificationTime
                        try managedObjectContext.save()
                    } catch {
                        print(__LINE__)
                        print(__FUNCTION__)
                        print(error)
                    }
                }
                
                self.dataFetchController.performFetch  {
                    self.expandableCells.removeAll()
                    
                    for object in self.dataFetchController.fetchedObjects {
                        if object.type! == "select" {
                            self.expandableCells.append(SelectCell.init(course: object.course!, title: object.title!, detail: "", what: object.what ?? "", when: object.when!))
                        }
                    }
                    let notificationMessage = "\(cellData.course!): \(cellData.title!)"
                    self.registerNotification(notificationMessage, when: newNotificationTime)
                    if cellData.when!.isGreaterThanDate(NSDate().localTime(NSDate().addDays(1))) {
                        self.removeRows(indexPath, titleForSection: titleForSection, numberOfRowsInSection: numberOfRowsInSection, cell: cell)
                    }
                    cell.hideSwipeAnimated(true)
                }
            })
            
            if NSDate().localTime().isLessThanDate(NSDate().localTime(cellData.when!.addDays(-1))) {
                ac.addAction(UIAlertAction(title: "Deň pred udalosťou", style: UIAlertActionStyle.Default) { action in
                    fetchRequest.entity = entityDescription
                    fetchRequest.predicate = NSPredicate(format: "SELF = %@", cellData)
                    
                    let newNotificationTime = NSDate().localTime(cellData.when!.addDays(-1))
                    do {
                        let o = try managedObjectContext.executeFetchRequest(fetchRequest).first! as! NotificationStack
                        o.whenNotify = newNotificationTime
                        try managedObjectContext.save()
                    } catch {
                        print(__LINE__)
                        print(__FUNCTION__)
                        print(error)
                    }
                    
                    self.dataFetchController.performFetch  {
                        self.expandableCells.removeAll()
                        
                        for object in self.dataFetchController.fetchedObjects {
                            if object.type! == "select" {
                                self.expandableCells.append(SelectCell.init(course: object.course!, title: object.title!, detail: "", what: object.what ?? "", when: object.when!))
                            }
                        }
                        let notificationMessage = "\(cellData.course!): \(cellData.title!)"
                        self.registerNotification(notificationMessage, when: newNotificationTime)
                        self.removeRows(indexPath, titleForSection: titleForSection, numberOfRowsInSection: numberOfRowsInSection, cell: cell)
                        cell.hideSwipeAnimated(true)
                    }
                })
            }
            
            ac.addAction(UIAlertAction(title: "Zrušiť", style: UIAlertActionStyle.Cancel) { action in
                cell.hideSwipeAnimated(true)
            })
            presentViewController(ac, animated: true, completion: nil)
            currentCellIndexPath = self.tableView.indexPathForCell(cell)!
            print(UIApplication.sharedApplication().scheduledLocalNotifications)
        }
        return false
    }
    
    private func removeRows(indexPath: NSIndexPath, titleForSection: String, numberOfRowsInSection: Int, cell: MGSwipeTableCell) {
        tableView.beginUpdates()
        if numberOfSectionsInTableView(self.tableView) == 0 { // removing last cell in last remaining section
            self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
        } else if numberOfRowsInSection == 1 { // if the section contains only only last cell, the whole section should be deleted
            self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
        } else {
            if titleForSection == "Registrace" && expanded {
                if numberOfRowsInSection > indexArray.count + 1 {
                    indexArray.append(self.tableView.indexPathForCell(cell)!)
                    self.tableView.deleteRowsAtIndexPaths(indexArray, withRowAnimation: .Automatic)
                } else {
                    self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
                }
                indexArray.removeAll()
            } else {
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        tableView.endUpdates()
    }
}

