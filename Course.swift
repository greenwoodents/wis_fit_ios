//
//  Course.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 30.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import Foundation
import CoreData

@objc(Course)
class Course: NSManagedObject
{
    func addTask(value: Task) {
        self.mutableSetValueForKey("tasks").addObject(value)
    }
    
    func getCourseTasks() -> [Task] {
        var tasks: [Task]
        tasks = self.tasks!.allObjects as! [Task]
        return tasks
    }
    
}
