//
//  Variant+CoreDataProperties.swift
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

extension Variant {

    @NSManaged var id: NSNumber?
    @NSManaged var limit: NSNumber?
    @NSManaged var registred: NSNumber?
    @NSManaged var title: String?
    @NSManaged var parentTask: Task?

}
