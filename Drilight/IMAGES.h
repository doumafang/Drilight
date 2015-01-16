//
//  IMAGES.h
//  Drilight
//
//  Created by doumaaaaaaaa on 15/1/11.
//  Copyright (c) 2015年 douma. All rights reserved.
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
