//
//  NotificationStack+CoreDataProperties.swift
//  
//
//  Created by Tomáš Ščavnický on 28.01.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension NotificationStack {

    @NSManaged var course: String?
    @NSManaged var id: NSNumber?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var what: String?
    @NSManaged var when: NSDate?
    @NSManaged var whenNotify: NSDate?
    @NSManaged var displayNotification: NSNumber?

}
