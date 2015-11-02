//
//  Task+CoreDataProperties.m
//  WIS
//
//  Created by Tomáš Ščavnický on 26.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Task+CoreDataProperties.h"

@implementation Task (CoreDataProperties)

@dynamic start;
@dynamic end;
@dynamic reg_start;
@dynamic reg_end;
@dynamic title;
@dynamic id;
@dynamic parentCourse;
@dynamic variants;

@end
