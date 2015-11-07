//
//  Task.swift
//  WIS
//
//  Created by Tomáš Ščavnický on 30.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//

import Foundation
import CoreData

@objc(Task)
class Task: NSManagedObject {

    func addVariant(value: Variant) {
        self.mutableSetValueForKey("variants").addObject(value)
    }
    
    func getTaskVariants() -> [Variant] {
        var variants: [Variant]
        variants = self.variants!.allObjects as! [Variant]
        return variants
    }

}
