//
//  AppDelegate.h
//  MySecondApp
//
//  Created by 新井脩司 on 2014/03/25.
//  Copyright (c) 2014年 sacrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Yokado.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *yokadoList;
@property (strong, nonatomic) Yokado *yokado;


@end
