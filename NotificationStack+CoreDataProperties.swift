//
//  NotificationStack+CoreDataProperties.swift
//  
//
//  Created by Tomáš Ščavnický on 10.11.15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension NotificationStack {

    @NSManaged var id: NSNumber?
    @NSManaged var course: String?
    @NSManaged var text: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var what: String?
    @NSManaged var when: NSDate?
    @NSManaged var read: NSNumber?

}
