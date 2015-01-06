//
//  IMAGES.h
//  Drilight
//
//  Created by doumaaaaaaaa on 14/12/23.
//  Copyright (c) 2014年 douma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SHOTS;

@interface IMAGES : NSManagedObject

@property (nonatomic, retain) NSString * hidpi;
@property (nonatomic, retain) NSString * normal;
@property (nonatomic, retain) NSString * teaser;
@property (nonatomic, retain) SHOTS *popular;

@end
