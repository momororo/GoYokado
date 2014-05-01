//
//  CustomAnnotation.m
//  MySecondApp
//
//  Created by 新井脩司 on 2014/05/01.
//  Copyright (c) 2014年 sacrew. All rights reserved.
//

#import "CustomAnnotation.h"


@implementation CustomAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)co newTitle:(NSString *)t newSubTitle:(NSString *)st;
{
    self = [super self];
    
    if(self != nil)
    {
        coordinate = co;
        title = t;
        subtitle = st;
    }
    
    return self;
}

@end

