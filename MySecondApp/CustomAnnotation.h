//
//  CustomAnnotation.h
//  MySecondApp
//
//  Created by 新井脩司 on 2014/05/01.
//  Copyright (c) 2014年 sacrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>
    
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
    
- (id)initWithCoordinates:(CLLocationCoordinate2D)co newTitle:(NSString *)t newSubTitle:(NSString *)st;


@end
