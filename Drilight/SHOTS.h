//
//  SHOTS.h
//  Drilight
//
//  Created by doumaaaaaaaa on 14/12/23.
//  Copyright (c) 2014年 douma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class COMMENTS, IMAGES, USER;

@interface SHOTS : NSManagedObject

@property (nonatomic, retain) NSString * attachments_count;
@property (nonatomic, retain) NSString * comments_count;
@property (nonatomic, retain) NSString * commentslastmodified;
@property (nonatomic, retain) NSString * created_at;
@property (nonatomic, retain) NSString * didlike;
@property (nonatomic, retain) NSNumber * i;
@property (nonatomic, retain) NSString * likes_count;
@property (nonatomic, retain) NSString * shot_description;
@property (nonatomic, retain) NSString * shotsid;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) id tags;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * views_count;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) IMAGES *images;
@property (nonatomic, retain) USER *user;
@property (nonatomic, retain) USER *likedby;
@end

@interface SHOTS (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(COMMENTS *)value;
- (void)removeCommentsObject:(COMMENTS *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

@end
