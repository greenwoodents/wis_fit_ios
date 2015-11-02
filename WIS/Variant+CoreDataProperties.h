//
//  Variant+CoreDataProperties.h
//  WIS
//
//  Created by Tomáš Ščavnický on 26.10.15.
//  Copyright © 2015 Tomas Scavnicky. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Variant.h"

NS_ASSUME_NONNULL_BEGIN

@interface Variant (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *registred;
@property (nullable, nonatomic, retain) NSNumber *limit;
@property (nullable, nonatomic, retain) Task *parentTask;

@end

NS_ASSUME_NONNULL_END
