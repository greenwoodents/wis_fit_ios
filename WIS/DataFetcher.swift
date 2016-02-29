//
//  DataFetcher.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 05.02.16.
//  Copyright © 2016 Tomas Scavnicky. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class DataFetcher {
    
    var sections = Array<Array<NotificationStack>>()
    
    var fetchedObjects: [NotificationStack] {
        var retNotifs = [NotificationStack]()
        for section in sections {
            for row in section {
                retNotifs.append(row)
            }
        }
        return retNotifs
    }
    
    func performFetch(callback: ()->Void) {
        sections.removeAll()
        let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "NotificationStack")
        let single = "single"
        let select = "select"
        let misc = "misc"
//        let menza = "menza"
        
        let primarySortDescriptor = NSSortDescriptor(key: "type", ascending: false)
        let secondarySortDescriptor = NSSortDescriptor(key: "course", ascending: true)
        
        let typePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [ NSPredicate(format: "type = %@", single),
            NSPredicate(format: "type = %@", misc),
            NSPredicate(format: "type = %@", select)])
        
        
        let nonRegisterPredicates = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "when >= %@", NSDate().localTime(NSDate().addDays(-2))),
            NSPredicate(format: "when <= %@", NSDate().localTime(NSDate().addDays(5)))])
        // rozsah whenNotify < teraz
        let laterNotificationPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "whenNotify < %@", NSDate().localTime())])
        
        
        let displayNotificationPredicate = NSPredicate(format: "displayNotification = %@", NSNumber(bool: true))
        
        let tmp = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, nonRegisterPredicates, laterNotificationPredicate, displayNotificationPredicate])
        
        fetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [tmp])
        
        
        
        do {
            
            let results = try moc.executeFetchRequest(fetchRequest) as! [NotificationStack]
            
            if !results.isEmpty {
                var currentType = results.first!.type
                var sectionCounter = 0
                sections.append([NotificationStack]())
                
                for notif in results {
                    if notif.type == currentType {
                        sections[sectionCounter].append(notif)
                    } else {
                        currentType = notif.type
                        sectionCounter = sectionCounter + 1
                        sections.append([NotificationStack]())
                        sections[sectionCounter].append(notif)
                    }
                }
            }
        } catch {
            print(error)
        }
        callback()
    }
    
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> NotificationStack {
        return sections[indexPath.section][indexPath.row]
    }
}