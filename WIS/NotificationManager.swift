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
    
    func parse(XMLString: String) {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let courseEntity =  NSEntityDescription.entityForName("Course", inManagedObjectContext:managedContext)
        let taskEntity = NSEntityDescription.entityForName("Task", inManagedObjectContext:managedContext)
        //let course = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext)
        
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
    
    public func createNotificationStack(XMLString: String) -> Bool {
        
        do {
            let document = try XMLDocument(string: XMLString as String)
            if let root = document.root {
                for element in root.children {



                    for item in element.children {
                    }
                }
            }
        } catch let error {
            print(error)
        }
        
        
        return true;
    }
}

