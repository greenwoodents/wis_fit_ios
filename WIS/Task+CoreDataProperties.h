//
//  Task+CoreDataProperties.h
//  WIS
//
//  Created by Tomáš Ščavnický on 26.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface Task (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *start;
@property (nullable, nonatomic, retain) NSDate *end;
@property (nullable, nonatomic, retain) NSDate *reg_start;
@property (nullable, nonatomic, retain) NSDate *reg_end;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSManagedObject *parentCourse;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *variants;

@end

@interface Task (CoreDataGeneratedAccessors)

- (void)addVariantsObject:(NSManagedObject *)value;
- (void)removeVariantsObject:(NSManagedObject *)value;
- (void)addVariants:(NSSet<NSManagedObject *> *)values;
- (void)removeVariants:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
