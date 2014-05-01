//
//  MapViewController.m
//  MySecondApp
//
//  Created by 新井脩司 on 2014/04/24.
//  Copyright (c) 2014年 sacrew. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Yokado.h"
#import "AppDelegate.h"
#import "CustomAnnotation.h"

@interface MapViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Yokado *yokado;

@end

@implementation MapViewController
@synthesize mapView;

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
    
    
    mapView.showsUserLocation = YES;
    mapView.userLocation.title = @"現在地";


    // ロケーションマネージャーを作成
	self.locationManager = CLLocationManager.new;
    if ([CLLocationManager locationServicesEnabled]) {
		self.locationManager.delegate = self;
		// 位置情報取得開始
		[_locationManager startUpdatingLocation];
	}else{
        NSLog(@"位置情報使えないよ><");
    }
    
    [self locationManager];
    
    [mapView removeAnnotations:mapView.annotations];


    
}

- (void)viewwillAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//経度緯度を参照（位置情報の取得）し、目的地までのルートを表示する
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    
    //appデリゲートに接続
    AppDelegate *ap = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    //リストの中から1店舗の情報をランダムで取得する
    _yokado = [self getRandomFromList:ap.yokadoList];

    //現在の緯度と経度を取得
    CLLocation *location = locations[(locations.count-1)];
    CLLocationCoordinate2D latlng = location.coordinate;
    NSLog(@" %f , %f ",latlng.latitude,latlng.longitude);
    
    //緯度と経度を取得し続けるため、取得の停止
    [self.locationManager stopUpdatingLocation];
    
    
    /* 経路を表示する設定 */
            // 現在地
            CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(latlng.latitude, latlng.longitude);
    
            // 目的地（ヨーカドー）
            CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(_yokado.latitude.floatValue, _yokado.longitude.floatValue);
            NSLog(@"%f ,%f",_yokado.latitude.floatValue,_yokado.longitude.floatValue);
    
            // CLLocationCoordinate2D から MKPlacemark を生成
            MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:fromCoordinate
                                                                addressDictionary:nil];
            MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:toCoordinate
                                                                addressDictionary:nil];
    
            // MKPlacemark から MKMapItem を生成
            MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
            MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
            // MKMapItem をセットして MKDirectionsRequest を生成
            MKDirectionsRequest *request = MKDirectionsRequest.new;
            request.source = fromItem;
            request.destination = toItem;
            request.requestsAlternateRoutes = YES;
    
            // MKDirectionsRequest から MKDirections を生成
            MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
            // 経路検索を実行
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
                {
                        if (error) return;
         
                        if ([response.routes count] > 0)
                            {
                                    MKRoute *route = (response.routes)[0];
                                    NSLog(@"distance: %.2f meter", route.distance);
             
            // 地図上にルートを描画
             [self.mapView addOverlay:route.polyline];
    /* 経路を表示する設定　おわり */
    
    /* 現在地・目的地のアノテーションの設定 */
            
            //現在地
            //NSString *title = @"現在地";
            //CustomAnnotation *ann = [[CustomAnnotation alloc]initWithCoordinates:latlng newTitle:title newSubTitle:nil];
            
            //目的地
            NSString *totitle = _yokado.name;
            CustomAnnotation *customAnnotation = [[CustomAnnotation alloc] initWithCoordinates:toCoordinate newTitle:totitle newSubTitle:nil];
            
                                
            //annotationをマップに追加
            [mapView addAnnotation:customAnnotation];
            //[mapView addAnnotation:ann];

             
    /*ナビゲーションバーのタイトルの設定
       細かい設定が可能なようです。*/
             //ナビゲーションバーに距離と目的地を表示
             NSString *distance = [NSString stringWithFormat:@"約%.0f km",route.distance/1000];
             
             UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
             //文の設定
             titleLabel.text = [NSString stringWithFormat:@"%@ %@",_yokado.address,distance];
             //フォントの設定
             titleLabel.font = [UIFont fontWithName:@"HiraMaruPro-W4" size:18];
             //背景色
             titleLabel.backgroundColor = [UIColor clearColor];
             //文字の色
             titleLabel.textColor = [UIColor blackColor];
             //位置の設定
             titleLabel.textAlignment = NSTextAlignmentCenter;
             //謎処理
             [titleLabel sizeToFit];
             
             self.navigationItem.titleView = titleLabel;
    /*ナビゲーションバーのタイトル設定おわり*/
             
             
    /*ピンの表示領域の設定*/
             double minLat = 9999.0;
             double minLng = 9999.0;
             double maxLat = -9999.0;
             double maxLng = -9999.0;
             double lat, lng;
             for (id<MKAnnotation> annotation in mapView.annotations){
                 lat = annotation.coordinate.latitude;
                 lng = annotation.coordinate.longitude;
                 //緯度の最大最小を求める
                 if(minLat > lat)
                     minLat = lat;
                 if(lat > maxLat)
                     maxLat = lat;
                 
                 //経度の最大最小を求める
                 if(minLng > lng)
                     minLng = lng;
                 if(lng > maxLng)
                     maxLng = lng;
             }
             CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat + minLat) / 2.0, (maxLng + minLng) / 2.0);
             MKCoordinateSpan span = MKCoordinateSpanMake((maxLat - minLat) * 2, (maxLng - minLng) * 2);    //左式の数値で変更可
             MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
             [mapView setRegion:[mapView regionThatFits:region] animated:YES];
             
                //地図に設定した内容を表示する
             [self.view addSubview:self.mapView];
    /*ピンの表示領域の設定おわり*/
         }
     }];
}


// 位置情報が取得失敗した場合にコールされる。
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if (error) {
		NSString* message = nil;
		switch ([error code]) {
                // アプリでの位置情報サービスが許可されていない場合
			case kCLErrorDenied:
				// 位置情報取得停止
				[self.locationManager stopUpdatingLocation];
				message = [NSString stringWithFormat:@"このアプリは位置情報サービスが許可されていません。"];
				break;
			default:
				message = [NSString stringWithFormat:@"位置情報の取得に失敗しました。"];
				break;
		}
		if (message) {
			// アラートを表示
			UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil
                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
}


#pragma mark - MKMapViewDelegate


// 地図上に描画するルートの色などを指定（これを実装しないと何も表示されない）
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.lineWidth = 5.0;
        routeRenderer.strokeColor = [UIColor redColor];
        return routeRenderer;
    }
    else {
        return nil;
    }
}

/*******************************************************************
                            アノテーション
*******************************************************************/
#pragma - mapkit delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation) {
        return nil;
    } else {
	MKAnnotationView *annotationView;
    
    // 再利用可能なannotationがあるかどうかを判断するための識別子を定義
    NSString *identifier = @"Pin";
    
    // "Pin"という識別子のついたannotationを使いまわせるかチェック
    annotationView = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    // 使い回しができるannotationがない場合、annotationの初期化
    if(annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    // 画像をannotationに設定設定
    annotationView.image = [UIImage imageNamed:@"flag.png"];
    annotationView.canShowCallout = YES;  // この設定で吹き出しが出る
    annotationView.annotation = annotation;
    
    
    //画像の位置を調整（左右，上下）
    annotationView.centerOffset = CGPointMake(0, -43);

    
    return annotationView;
    }
}

/*******************************************************************
                        アノテーション　おわり
*******************************************************************/



/*******************************************************
 引数のyokadoListからランダムに選ぶメソッド
 yokadoオブジェクトを返す
*******************************************************/
 
-(Yokado *)getRandomFromList:(NSMutableArray *)yokadoList
{
    //乱数発生
    NSInteger value = (int) arc4random_uniform(yokadoList.count);
    
    //乱数をもとに配列から取り出す
    return yokadoList[value];
    
    
}
/*******************************************************
 引数のyokadoListからランダムに選ぶメソッド　おわり
 *******************************************************/




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
