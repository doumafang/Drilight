//
//  BUCKETS.h
//  Drilight
//
//  Created by doumaaaaaaaa on 15/1/11.
//  Copyright (c) 2015年 douma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SHOTS, USER;

@interface BUCKETS : NSManagedObject

@property (nonatomic, retain) NSString * bucketdescription;
@property (nonatomic, retain) NSString * bucketID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * shots_count;
@property (nonatomic, retain) NSString * shots_lastmodified;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) USER *user;
@property (nonatomic, retain) NSSet *shots;
@end

@interface BUCKETS (CoreDataGeneratedAccessors)

- (void)addShotsObject:(SHOTS *)value;
- (void)removeShotsObject:(SHOTS *)value;
- (void)addShots:(NSSet *)values;
- (void)removeShots:(NSSet *)values;

@end
