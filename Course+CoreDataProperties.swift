//
//  Course+CoreDataProperties.swift
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

extension Course {

    @NSManaged var abbrv: String?
    @NSManaged var credits: NSNumber?
    @NSManaged var csid: NSNumber?
    @NSManaged var points: NSNumber?
    @NSManaged var sem: String?
    @NSManaged var title_cs: String?
    @NSManaged var title_en: String?
    @NSManaged var tasks: NSSet?

}
