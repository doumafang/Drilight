//
//  USER.h
//  Drilight
//
//  Created by doumaaaaaaaa on 14/12/28.
//  Copyright (c) 2014年 douma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class COMMENTS, SHOTS, USER;

@interface USER : NSManagedObject

@property (nonatomic, retain) NSString * avatar_url;
@property (nonatomic, retain) NSString * followers_count;
@property (nonatomic, retain) NSString * following_lastmodified;
@property (nonatomic, retain) NSString * followings_count;
@property (nonatomic, retain) NSNumber * i;
@property (nonatomic, retain) NSString * likes_count;
@property (nonatomic, retain) NSString * likes_lastmodified;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pro;
@property (nonatomic, retain) NSString * shots_count;
@property (nonatomic, retain) NSString * shots_lastmodified;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * user_description;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * web;
@property (nonatomic, retain) NSString * followers_lastmodified;
@property (nonatomic, retain) COMMENTS *comments;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *following;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) NSSet *shots;
@property (nonatomic, retain) USER *followingby;
@property (nonatomic, retain) USER *followersby;
@end

@interface USER (CoreDataGeneratedAccessors)

- (void)addFollowersObject:(USER *)value;
- (void)removeFollowersObject:(USER *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addFollowingObject:(USER *)value;
- (void)removeFollowingObject:(USER *)value;
- (void)addFollowing:(NSSet *)values;
- (void)removeFollowing:(NSSet *)values;

- (void)addLikesObject:(SHOTS *)value;
- (void)removeLikesObject:(SHOTS *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;

- (void)addShotsObject:(SHOTS *)value;
- (void)removeShotsObject:(SHOTS *)value;
- (void)addShots:(NSSet *)values;
- (void)removeShots:(NSSet *)values;

@end
