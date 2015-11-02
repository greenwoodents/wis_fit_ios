//
//  Parser.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 25.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import Foundation
import Fuzi
import CoreData

class Data {
    
    static let sharedInstance = Data()
    
    var courses = [NSManagedObject]()
    
    /*
    
    */
    func saveNewData(XMLString xml: String) {
        do {
            let document = try XMLDocument(string: xml as String)
            if let root = document.root {
                for element in root.children {
                    var cesky = ""
                    var english = ""
                    
                    
                    
                    for item in element.children {
                        if (item.attributes["lang"] == "cs") {
                            cesky = item.stringValue
                            //print(cesky)
                        } else if (item.attributes["lang"] == "en") {
                            english = item.stringValue
                            //print(english)
                        }
                    }
                    
                    self.save_course(element.attributes["id"]!, abbreviation: element.attributes["abbrv"]!, cesky: cesky, english: english, semester: element.attributes["sem"]!, credits: element.attributes["credits"]!, points: element.attributes["points"]!)
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    
    
    func save_course(id: String, abbreviation abbrv: String, cesky title_cs: String, english title_en: String, semester sem: String, credits: String, points: String)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("Course", inManagedObjectContext:managedContext)
        let course = NSManagedObject(entity: entity!,insertIntoManagedObjectContext: managedContext)
        
        
        //3
        course.setValue(abbrv, forKey: "abbrv")
        course.setValue(NSNumber(integer: Int(credits as String)!), forKey: "credits")
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
    
    
    
    
    
    
    
    
    
    
}