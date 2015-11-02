//
//  Task+CoreDataProperties.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 30.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Task {

    @NSManaged var end: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var reg_end: NSDate?
    @NSManaged var reg_start: NSDate?
    @NSManaged var start: NSDate?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var parentCourse: Course?
    @NSManaged var variants: NSSet?

}
