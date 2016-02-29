//
//  Notification.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 30.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//


/*

prepis pristup do Core Data tak aby nespomaloval hlavne vlakno

*/

import Foundation
import CoreData
import Fuzi
import SwiftyJSON

public class NotificationManager
{
    struct CourseSruct {
        var id: Int
        var abbrv: String
        var points: Int
        var credits: Int
        var sem: String
        var title_cs: String?
        var title_en: String?
        var tasks: [TaskStruct]?
    }
    
    struct TaskStruct {
        var id: Int? = 0
        var type: String? = ""
        var title: String? = ""
        var start: String? = ""
        var end: String? = ""
        var reg_start: String? = ""
        var reg_end: String? = ""
        var variants: [VariantStruct]? = nil
    }
    
    struct VariantStruct {
        var id: Int? = 0
        var registered: Int? = 0
        var limit: Int? = 0
        var title: String? = ""
    }
    
    var courseManagedObjects = [NSManagedObject]()
    var courseResults = [AnyObject]()
    var taskResults = [AnyObject]()
    var courses = [CourseSruct]()
    var tasks = [TaskStruct]()
    var variants = [VariantStruct]()
    let dateFormatter = NSDateFormatter()
    
    
    /**
    * Parses XMLString into a XMLDocument
    * Creates new list of courses, tasks and variants based on the XMLDocument
    */
    
    func parse(XMLString: String) -> Bool {
        do {
            let document = try XMLDocument(string: XMLString as String)
            if let root = document.root {
                for element in root.children {
                    var courseStruct = CourseSruct(id: Int(element.attributes["csid"]! as String)!,
                        abbrv: element.attributes["abbrv"]!,
                        points: Int(element.attributes["points"]! as String)!,
                        credits: Int(element.attributes["credits"]! as String)!,
                        sem: element.attributes["sem"]!,
                        title_cs: nil,
                        title_en: nil,
                        tasks: nil)
                    
                    for item in element.children {
                        if item.attributes["lang"] == "cs" {
                            courseStruct.title_cs = item.stringValue
                        } else if item.attributes["lang"] == "en" {
                            courseStruct.title_en = item.stringValue
                        } else if item.tag == "item" {
                            var task = TaskStruct()
                            task.id = Int(item.attributes["id"]! as String)
                            task.type = item.attributes["type"]
                            if let t = item.firstChild(tag: "title") {
                                task.title = t.stringValue
                            }
                            task.start = item.attributes["start"]
                            task.end = item.attributes["end"]
                            task.reg_start = item.attributes["reg_start"]
                            task.reg_end = item.attributes["reg_end"]
                            
                            if let type = task.type {
                                if type == "select" {
                                    for variant in item.children {
                                        if variant.tag == "variant" {
                                            var variantStruct = VariantStruct()
                                            if let id = variant.attributes["id"] {
                                                variantStruct.id = Int(id as String)
                                            }
                                            if let limit = variant.attributes["limit"] {
                                                variantStruct.limit = Int(limit as String)
                                            }
                                            if let registered = variant.attributes["registered"] {
                                                variantStruct.registered = Int(registered as String)
                                            }
                                            if let title = variant.firstChild(tag: "title") {
                                                variantStruct.title = title.stringValue
                                            }
                                            variants.append(variantStruct)
                                            
                                        } // if variant.tag == "variant"
                                    } // for variant in item.children
                                    task.variants = variants
                                    variants.removeAll()
                                }
                            }
                            tasks.append(task)
                        } // if item.tag == "item"
                    } // for item in element.children
                    courseStruct.tasks = tasks
                    tasks.removeAll()
                    courses.append(courseStruct)
                } // for element in root.children
            }
        } catch let error {
            print(__LINE__)
            print(__FUNCTION__)
            print(error)
            return false
        }
        return true
    }
    
    /*
    * Stores current courses = [Course] into Core Data
    * If courses is empty -> false
    *
    */
    
    
    
    
    
    
    
    func saveData() -> Bool {

        if courses.isEmpty {
            return false
        }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        for course in courses {
            let courseMO = NSEntityDescription.insertNewObjectForEntityForName("Course", inManagedObjectContext: managedContext) as! Course
            courseMO.csid = course.id
            courseMO.abbrv = course.abbrv
            courseMO.sem = course.sem
            courseMO.points = course.points
            courseMO.credits = course.credits
            courseMO.title_cs = course.title_cs
            courseMO.title_en = course.title_en
            
            if !course.tasks!.isEmpty {
                
                for task in course.tasks! {
                    let taskMO = NSEntityDescription.insertNewObjectForEntityForName("Task", inManagedObjectContext: managedContext) as! Task
                    let dateFormater = NSDateFormatter()
                    
                    taskMO.parentCourse = courseMO
                    taskMO.id = task.id
                    if let type = task.type {
                        taskMO.type = type
                    }
                    if let title = task.title {
                        taskMO.title = title
                    }
                    dateFormater.dateFormat = "yyy-MM-dd"
                    if let start = task.start {
                        taskMO.start = dateFormater.dateFromString(start)
                    }
                    if let end = task.end {
                        taskMO.end = dateFormater.dateFromString(end)
                    }
                    dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    if let reg_start = task.reg_start {
                        taskMO.reg_start = dateFormater.dateFromString(reg_start)
                    }
                    if let reg_end = task.reg_end {
                        taskMO.reg_end = dateFormater.dateFromString(reg_end)
                    }
                    if let _ = task.variants {
                        if !task.variants!.isEmpty {
                            for variant in task.variants! {
                                let variantMO = NSEntityDescription.insertNewObjectForEntityForName("Variant", inManagedObjectContext: managedContext) as! Variant
                                
                                variantMO.id = variant.id!
                                variantMO.limit = variant.limit!
                                variantMO.registred = variant.registered!
                                variantMO.title = variant.title!
                                variantMO.parentTask = taskMO
                                
                                taskMO.addVariant(variantMO)
                            }
                        }
                    }
                    courseMO.addTask(taskMO)
                }
            }
        }
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        return true
    }
    
    

    
    
    
    func deleteCoreData() {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let storeURL = managedContext.persistentStoreCoordinator?.URLForPersistentStore(((managedContext.persistentStoreCoordinator)?.persistentStores.last)!)
        managedContext.performBlock {
            managedContext.reset()
            
            do {
                try managedContext.persistentStoreCoordinator?.removePersistentStore((managedContext.persistentStoreCoordinator?.persistentStores.last)!)
                let defaultManager = NSFileManager()
                try defaultManager.removeItemAtURL(storeURL!)
                try managedContext.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                print(__LINE__)
                print(__FUNCTION__)
                print(error)
            }
        }
    } // deleteCoreData
    
    
    
    
    
    
    
    
    public func createNotificationStack() -> Bool {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
//        fetchRequest.predicate = NSPredicate(format: "type == %@", "single")
        
        do {
            let tasksMOs = try managedContext.executeFetchRequest(fetchRequest) as! [Task]
            if !tasksMOs.isEmpty {
                for task in tasksMOs {
                    if task.type == "select" {
                        if let reg_start = task.reg_start {
                            let notif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedContext) as! NotificationStack
                            notif.when = reg_start
                            notif.whenNotify = notif.when!.addDays(-5)
                            notif.what = "ZAČÁTEK REGISTRACE"
                            notif.course = task.parentCourse?.abbrv!
                            notif.title = task.title!
                            notif.type = task.type!
                            
                            do {
                                try managedContext.save()
                            } catch let error as NSError  {
                                print("Could not save \(error), \(error.userInfo)")
                            }
                        }
                        
                        if let reg_end = task.reg_end {
                            let notif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedContext) as! NotificationStack
                            notif.when = reg_end
                            notif.whenNotify = notif.when!.addDays(-5)
                            notif.what = "KONEC REGISTRACE"
                            notif.course = task.parentCourse?.abbrv!
                            notif.title = task.title!
                            notif.type = task.type!
                            
                            do {
                                try managedContext.save()
                            } catch let error as NSError  {
                                print("Could not save \(error), \(error.userInfo)")
                            }
                        }
                    }
                    
                    if let start = task.start {
                        let notif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedContext) as! NotificationStack
                        notif.when = start
                        notif.whenNotify = notif.when!.addDays(-5)
                        notif.what = "ZAČÁTEK"
                        notif.course = task.parentCourse?.abbrv!
                        notif.title = task.title!
                        notif.type = task.type!
                        
                        do {
                            try managedContext.save()
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                    }
                    
                    if let end = task.end {
                        let notif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedContext) as! NotificationStack
                        notif.when = end
                        notif.whenNotify = notif.when!.addDays(-5)
                        notif.what = "KONEC"
                        notif.course = task.parentCourse?.abbrv!
                        notif.title = task.title!
                        notif.type = task.type!
                        
                        do {
                            try managedContext.save()
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                    }
                }
                return false;
            } else {
                print("Is empty")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return true;
    }
    
    
    
    
    
    
    
    

    
    func parseAndSaveExternalSources(source: AnyObject) {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let json = JSON(source)
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        for (course, subJson):(String, JSON) in json {
            for (termin, _):(String, JSON) in subJson {
                let notif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedContext) as! NotificationStack
                notif.type = "misc"
                notif.course = course
                notif.when = dateFormater.dateFromString(json[course][termin].stringValue)
                notif.whenNotify = notif.when!.addDays(-5)
                notif.title = termin
                notif.displayNotification = NSNumber(bool: true)
            }
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
    
    
    
    
    
    func registerNotification(notif: NotificationStack) {
        let notification = UILocalNotification()
        notification.alertBody = notif.title
        notification.alertAction = "Slide to view"
        notification.fireDate = notif.whenNotify
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["":""]
        notification.category = nil
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    func printStructs() {
        print("PRINTING STRUCTS:\n\n\n\n\n\n\n\n")
        for course in courses {
            print("title_cs: \(course.title_cs)")
            print("id: \(course.id)")
            print("abbrv: \(course.abbrv)")
            print("sem: \(course.sem)")
            print("points: \(course.points)")
            print("credits: \(course.credits)")
            print("title_en: \(course.title_en)")
            if let uTasks = course.tasks {
                for task in uTasks {
                    print("\ttask title: \(task.title)")
                    print("\ttask id: \(task.id)")
                    print("\ttask type: \(task.type)")
                    print("\ttask start: \(task.start)")
                    print("\ttask end: \(task.end)")
                    print("\ttask reg_start: \(task.reg_start)")
                    print("\ttask reg_end: \(task.reg_end)")
                    print("\t====================================================================================================")
                    if let uVariants = task.variants {
                        for variant in uVariants {
                            print("\t\tvariant title: \(variant.title)")
                            print("\t\tvariant id: \(variant.id)")
                            print("\t\tvariant registered: \(variant.registered)")
                            print("\t\tvariant limit: \(variant.limit)")
                            print("\t\t====================================================================================================")
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    func saveNotifications(XMLString: String) {
        
        parse(XMLString)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        for course in courses {
            
            if !course.tasks!.isEmpty {
                
                for task in course.tasks! {
                    
                    let dateFormater = NSDateFormatter()
                    
                    
                    if let reg_start = task.reg_start {
                        let notif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedContext) as! NotificationStack
                        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        notif.when = dateFormater.dateFromString(reg_start)
                        notif.whenNotify = notif.when!.addDays(-5)
                        notif.what = "Začiatok registrácie"
                        notif.course = course.abbrv
                        notif.title = task.title!
                        notif.type = task.type!
                        notif.displayNotification = NSNumber(bool: true)
                        do {
                            try managedContext.save()
                        } catch let error as NSError  {
                            print(__LINE__)
                            print(__FUNCTION__)
                            print(error)
                        }
                    }
                    
                    if let reg_end = task.reg_end {
                        let notif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedContext) as! NotificationStack
                        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        notif.when = dateFormater.dateFromString(reg_end)
                        notif.whenNotify = notif.when!.addDays(-7)
                        notif.what = "Koniec registrácie"
                        notif.course = course.abbrv
                        notif.title = task.title!
                        notif.type = task.type!
                        notif.displayNotification = NSNumber(bool: true)
                        do {
                            try managedContext.save()
                        } catch let error as NSError  {
                            print(__LINE__)
                            print(__FUNCTION__)
                            print(error)
                        }
                    }
                    
                    if let start = task.start {
                        let notif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedContext) as! NotificationStack
                        dateFormater.dateFormat = "yyyy-MM-dd"
                        notif.when = dateFormater.dateFromString(start)
                        notif.whenNotify = notif.when!.addDays(-7)
                        notif.what = "Zahájenie"
                        notif.course = course.abbrv
                        notif.title = task.title!
                        notif.type = task.type!
                        notif.displayNotification = NSNumber(bool: true)
                        do {
                            try managedContext.save()
                        } catch let error as NSError  {
                            print(__LINE__)
                            print(__FUNCTION__)
                            print(error)
                        }
                    }
                    
                    if let end = task.end {
                        let notif = NSEntityDescription.insertNewObjectForEntityForName("NotificationStack", inManagedObjectContext: managedContext) as! NotificationStack
                        dateFormater.dateFormat = "yyyy-MM-dd"
                        notif.when = dateFormater.dateFromString(end)
                        notif.whenNotify = notif.when!.addDays(-7)
                        notif.what = "Deadline"
                        notif.course = course.abbrv
                        notif.title = task.title!
                        notif.type = task.type!
                        notif.displayNotification = NSNumber(bool: true)
                        do {
                            try managedContext.save()
                        } catch let error as NSError  {
                            print(__LINE__)
                            print(__FUNCTION__)
                            print(error)
                        }
                    }
                    saveData()
                }
            }
        }
    }
    
    func updateNotifications(XMLString: String) {
        
        func compare<T: Equatable>(inout first: T, _ second: T) -> Bool {
            if first == second {
                return false
            } else {
                first = second
                return true
            }
        }
        
        parse(XMLString)
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

        // urob pre NotificationStack a Course paralelne vlakna
        
        for course in courses {
            var fetchRequest = NSFetchRequest(entityName: "Course")
            fetchRequest.predicate = NSPredicate(format: "abbrv = %@", course.abbrv)
            do  {
                let courseMO = try managedObjectContext.executeFetchRequest(fetchRequest).first as! Course
                compare(&courseMO.points!, course.points) // testni, ak true, potom daj userovi vediet
                
                // PRIDAT CHECK CI SU AJ TASKY ROVNAKE!!!
                
                try managedObjectContext.save()
            } catch {
                print(__LINE__)
                print(__FUNCTION__)
                print(error)
                
            }
            
            
            
            if let tasks = course.tasks {
                for task in tasks {
                    fetchRequest = NSFetchRequest(entityName: "Task")
                    fetchRequest.predicate = NSPredicate(format: "title = %@", task.title!)
                    do {
                        let taskMO = try managedObjectContext.executeFetchRequest(fetchRequest).first as! Task
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        compare(&taskMO.type!, task.type!)
                        if task.start != nil {
                            compare(&taskMO.start!, dateFormatter.dateFromString(task.start!)!)
                        } else if task.end != nil {
                            compare(&taskMO.end!, dateFormatter.dateFromString(task.end!)!)
                        } else if task.reg_start != nil {
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            compare(&taskMO.reg_start!, dateFormatter.dateFromString(task.reg_start!)!)
                        } else if task.reg_end != nil {
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            compare(&taskMO.reg_end!, dateFormatter.dateFromString(task.reg_end!)!)
                        }
                        
                        
                        
                        
                        
                    } catch {
                        print(__LINE__)
                        print(__FUNCTION__)
                        print(error)
                    }
                    
                }
            }
        }
    }
}

func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    if lhs.isEqualToDate(rhs) {
        return true
    } else {
        return false
    }
}
