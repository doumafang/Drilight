//
//  COMMENTS.h
//  Drilight
//
//  Created by doumaaaaaaaa on 15/1/3.
//  Copyright (c) 2015年 douma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SHOTS, USER;

@interface COMMENTS : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * comment_id;
@property (nonatomic, retain) NSString * didlike;
@property (nonatomic, retain) NSNumber * i;
@property (nonatomic, retain) NSString * likes_count;
@property (nonatomic, retain) NSString * updated_at;
@property (nonatomic, retain) SHOTS *shots;
@property (nonatomic, retain) USER *user;

@end
