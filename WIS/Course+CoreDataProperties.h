//
//  Course+CoreDataProperties.h
//  WIS
//
//  Created by Tomáš Ščavnický on 26.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Course.h"

NS_ASSUME_NONNULL_BEGIN

@interface Course (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *abbrv;
@property (nullable, nonatomic, retain) NSNumber *credits;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *points;
@property (nullable, nonatomic, retain) NSString *sem;
@property (nullable, nonatomic, retain) NSString *title_cs;
@property (nullable, nonatomic, retain) NSString *title_en;
@property (nullable, nonatomic, retain) NSSet<Task *> *tasks;

@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet<Task *> *)values;
- (void)removeTasks:(NSSet<Task *> *)values;

@end

NS_ASSUME_NONNULL_END
