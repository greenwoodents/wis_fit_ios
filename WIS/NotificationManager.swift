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
            printStructs()
        } catch let error {
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

        if !courses.isEmpty {
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
                    taskMO.type = task.type
                    taskMO.title = task.title
                    dateFormater.dateFormat = "yyy-MM-dd"
                    taskMO.start = dateFormater.dateFromString(task.start!)
                    taskMO.end = dateFormater.dateFromString(task.end!)
                    dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    taskMO.reg_start = dateFormater.dateFromString(task.reg_start!)
                    taskMO.reg_end = dateFormater.dateFromString(task.reg_end!)
                    
                    
                    if !task.variants!.isEmpty {
                        for variant in task.variants! {
                            let variantMO = NSEntityDescription.insertNewObjectForEntityForName("Variant", inManagedObjectContext: managedContext) as! Variant
                            
                            variantMO.id = variant.id
                            variantMO.limit = variant.limit
                            variantMO.registred = variant.registered
                            variantMO.title = variant.title
                            variantMO.parentTask = taskMO
                            
                            taskMO.addVariant(variantMO)
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
