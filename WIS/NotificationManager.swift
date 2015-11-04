//
//  Notification.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 30.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import Foundation
import CoreData
import Fuzi

public class NotificationManager
{
    struct CourseShort {
        var id: Int
        var abbrv: String
        var points: Int
        var credits: Int
        var sem: String
        var title_cs: String?
        var title_en: String?
        var tasks: [Task]?
    }
    
    struct Task {
        var id: Int? = 0
        var type: String? = ""
        var start: String? = ""
        var end: String? = ""
        var reg_start: String? = ""
        var reg_end: String? = ""
        var variants: [Variant]? = nil
    }
    
    struct Variant {
        var id: Int? = 0
        var registered: Int? = 0
        var limit: Int? = 0
        var title: String? = ""
    }
    
    var courseManagedObjects = [NSManagedObject]()
    var courseResults = [AnyObject]()
    var taskResults = [AnyObject]()
    var courses = [CourseShort]()
    let dateFormatter = NSDateFormatter()
    
    /**
    * Creates Course and Task entities in Core Data
    * No courses nor tasks have been saved yet -> true
    * Courses and tasks have been saved befor (not first usage) -> false     
    * TODO: link relationships between Tasks and Courses, if there already exists a database of Courses or Tasks, call updateCoursesAndTasks()
    */
    
    func parse(XMLString: String) -> Bool {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let courseEntity =  NSEntityDescription.entityForName("Course", inManagedObjectContext:managedContext)
        let taskEntity = NSEntityDescription.entityForName("Task", inManagedObjectContext:managedContext)
        //let course = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext)
        
        let courseFetchRequest = NSFetchRequest(entityName: "Course")
        let taskFetchRequest = NSFetchRequest(entityName: "Task")
        
        do {
            courseResults = try managedContext.executeFetchRequest(courseFetchRequest)
            taskResults = try managedContext.executeFetchRequest(taskFetchRequest)
        } catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
        
        if courseResults.isEmpty || taskResults.isEmpty {
            do {
                let document = try XMLDocument(string: XMLString as String)
                if let root = document.root {
                    for element in root.children {
                        var courseStruct = CourseShort(id: Int(element.attributes["csid"]! as String)!,
                            abbrv: element.attributes["abbrv"]!,
                            points: Int(element.attributes["points"]! as String)!,
                            credits: Int(element.attributes["credits"]! as String)!,
                            sem: element.attributes["sem"]!,
                            title_cs: nil,
                            title_en: nil,
                            tasks: nil)
                        
                        var tasks = [Task]()
                        for item in element.children {
                            if item.attributes["lang"] == "cs" {
                                courseStruct.title_cs = item.stringValue
                            } else if item.attributes["lang"] == "en" {
                                courseStruct.title_en = item.stringValue
                            } else if item.tag != "accreditation" {
                                var task = Task()
                                task.id = Int(item.attributes["id"]! as String)
                                task.type = item.attributes["type"]
                                task.start = item.attributes["start"]
                                task.end = item.attributes["end"]
                                task.reg_start = item.attributes["reg_start"]
                                task.reg_end = item.attributes["reg_end"]
                                tasks.append(task)
                                
                                if let type = task.type {
                                    if type == "select" {
                                        let itemDocument = try XMLDocument(string: "\(item)")
                                        if let itemRoot = itemDocument.root {
                                            var variants = [Variant]()
                                            for variant in itemRoot.children {
                                                var variantStruct = Variant()
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
                                            } // for variant in itemRoot.children
                                            print("=====================================================================")
                                            print("variants: \(variants)")
                                            print("=====================================================================")
                                            task.variants = variants
                                        }
                                    }
                                }
                            }
                        } // for item in element.children
                        courseStruct.tasks = tasks
                        courses.append(courseStruct)
                    } // for element in root.children
                }
            } catch let error {
                print(error)
            }
            return true;
        } else {
            return false;
        }
    }
    
    func saveData() {
//        do {
//            let document = try XMLDocument(string: "" as String)
//            if let root = document.root {
//                for element in root.children {
//                    let courseStruct = CourseShort(id: Int(element.attributes["csid"]! as String)!,
//                        abbrv: element.attributes["abbrv"]!,
//                        points: Int(element.attributes["points"]! as String)!,
//                        credits: Int(element.attributes["credits"]! as String)!,
//                        sem: element.attributes["sem"]!,
//                        title_cs: "",
//                        title_en: "")
//                    courses.append(courseStruct)
//                    
//                    
//                    let course = NSManagedObject(entity: courseEntity!,insertIntoManagedObjectContext: managedContext) as! Course
//                    course.csid = NSNumber(integer: Int(element.attributes["csid"]! as String)!)
//                    course.abbrv = element.attributes["abbrv"]!
//                    course.sem = element.attributes["sem"]
//                    course.points = NSNumber(integer: Int(element.attributes["points"]! as String)!)
//                    course.credits = NSNumber(integer: Int(element.attributes["credits"]! as String)!)
//                    
//                    for item in element.children {
//                        let task = NSManagedObject(entity: taskEntity!, insertIntoManagedObjectContext: managedContext) as! Task
//                        
//                        task.parentCourse = course
//                        
//                        if item.attributes["lang"] == "cs" {
//                            task.title = course.title_cs
//                        } else if item.attributes["lang"] == "en" {
//                            task.title = course.title_en
//                        }
//                        
//                        if let id = item.attributes["id"] {
//                            task.id = NSNumber(integer: Int(id as String)!)
//                        }
//                        if let type = item.attributes["type"] {
//                            task.type = type
//                        }
//                        if let reg_start = item.attributes["reg_start"] {
//                            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
//                            task.reg_start = dateFormatter.dateFromString(reg_start)
//                        }
//                        if let reg_end = item.attributes["reg_end"] {
//                            dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
//                            task.reg_end = dateFormatter.dateFromString(reg_end)
//                        }
//                        if let start = item.attributes["start"] {
//                            dateFormatter.dateFormat = "yyyy-MM-dd"
//                            task.start = dateFormatter.dateFromString(start)
//                        }
//                        if let end = item.attributes["end"] {
//                            dateFormatter.dateFormat = "yyyy-MM-dd"
//                            task.end = dateFormatter.dateFromString(end)
//                        }
//                        
//                    }
//                    
//                    do {
//                        try managedContext.save()
//                        courseManagedObjects.append(course)
//                    } catch let error as NSError  {
//                        print("Could not save \(error), \(error.userInfo)")
//                    }
//                }
//            }
//        } catch let error {
//            print(error)
//        }
    }

    /**
    * Updates Course and Task entities in Core Data
    * Some Uprades were made -> true
    * No updates were made -> false
    * TODO: implement
    */
    func updateCoursesAndTasks(Courses: String) -> Bool {//[CourseShort]) -> Bool {
        
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Course")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            courseManagedObjects = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
//        for course in courseManagedObjects {
//            if let abbrv = course.valueForKey("abbrv") {
//                print(abbrv)
//            }
//            
//        }
        
        
        
        
        return true;
    }
    
    /**
    * Creates notification stack
    * Success -> true
    * Already existing notification stack -> false
    */
    public func createNotificationStack(XMLString: String) -> Bool {
        
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "NotificationStack")
        
        do {
            let result = try managedContext.executeFetchRequest(fetchRequest)
            if !result.isEmpty {
                // stack already exists
                return false;
            } else {
                print("Is empty")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return true;
    }
    
    /**
     * Updates notification stack
     * If there were made any changes in notification stack -> true.
     * If no changes were made or there is no notification stack -> false.
     */
    func updateNotificationStack(XMLString: String) -> Bool {
        return true;
    }
}

