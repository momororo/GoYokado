//
//  Yokado.h
//  MySecondApp
//
//  Created by yasutomo on 2014/04/28.
//  Copyright (c) 2014年 sacrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Yokado : NSObject

//店名
@property(strong,nonatomic) NSString *name;

//住所
@property(strong,nonatomic) NSString *address;

//緯度
@property(strong,nonatomic) NSString *latitude;

//経度
@property(strong,nonatomic) NSString *longitude;

@end
