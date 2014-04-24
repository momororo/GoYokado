//
//  MapViewController.m
//  MySecondApp
//
//  Created by 新井脩司 on 2014/04/24.
//  Copyright (c) 2014年 sacrew. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    clm = CLLocationManager.new;    //初期化
    clm.delegate = self;
    clm.desiredAccuracy = kCLLocationAccuracyHundredMeters;     //位置の精度（例は１００ｍスケール
    clm.distanceFilter = kCLDistanceFilterNone;                 //位置情報更新の距離（例はいつでも更新）100mの時は100にする
    [clm startUpdatingLocation];                                //位置情報取得開始
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    MKCoordinateRegion region = _mapView.region;                    //表示領域の支持
    region.center.latitude = newLocation.coordinate.latitude;       //表示領域の中心緯度
    region.center.longitude = newLocation.coordinate.longitude;     //表示領域の中心経度
    region.span.latitudeDelta = 0.02;                               //表示範囲（度）ズーム
    region.span.longitudeDelta = 0.02;                              //表示範囲（度）ズーム
    [_mapView setRegion:region animated:YES];                       //表示開始
}




-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
