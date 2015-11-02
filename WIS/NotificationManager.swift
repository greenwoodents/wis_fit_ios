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
    var courses = [NSManagedObject]()
    let dateFormatter = NSDateFormatter()
    var courseResults = [AnyObject]()
    var taskResults = [AnyObject]()
    
    /**
    * Creates Course and Task entities in Core Data
    * TODO: link relationships between Tasks and Courses, if there already exists a database of Courses or Tasks, call updateCoursesAndTasks()
    */
    
    func parse(XMLString: String) {
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
                        let course = NSManagedObject(entity: courseEntity!,insertIntoManagedObjectContext: managedContext) as! Course
                        
                        course.csid = NSNumber(integer: Int(element.attributes["csid"]! as String)!)
                        course.abbrv = element.attributes["abbrv"]!
                        course.sem = element.attributes["sem"]
                        course.points = NSNumber(integer: Int(element.attributes["points"]! as String)!)
                        course.credits = NSNumber(integer: Int(element.attributes["credits"]! as String)!)
                        
                        for item in element.children {
                            let task = NSManagedObject(entity: taskEntity!, insertIntoManagedObjectContext: managedContext) as! Task
                            
                            task.parentCourse = course
                            
                            if item.attributes["lang"] == "cs" {
                                task.title = course.title_cs
                            } else if item.attributes["lang"] == "en" {
                                task.title = course.title_en
                            }
                            
                            if let id = item.attributes["id"] {
                                task.id = NSNumber(integer: Int(id as String)!)
                            }
                            if let type = item.attributes["type"] {
                                task.type = type
                            }
                            if let reg_start = item.attributes["reg_start"] {
                                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
                                task.reg_start = dateFormatter.dateFromString(reg_start)
                            }
                            if let reg_end = item.attributes["reg_end"] {
                                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
                                task.reg_end = dateFormatter.dateFromString(reg_end)
                            }
                            if let start = item.attributes["start"] {
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                task.start = dateFormatter.dateFromString(start)
                            }
                            if let end = item.attributes["end"] {
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                task.end = dateFormatter.dateFromString(end)
                            }
                            
                        }
                        
                        do {
                            try managedContext.save()
                            courses.append(course)
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                    }
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    /**
    * Updates Course and Task entities in Core Data
    * Some Uprades were made -> true
    * No updates were made -> false
    * TODO: implement
    */
    func updateCoursesAndTasks() -> Bool {
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

