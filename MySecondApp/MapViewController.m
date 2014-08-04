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

BOOL mapFlag;

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
    

    // ロケーションマネージャーを作成
	self.locationManager = CLLocationManager.new;
    
    //　ロケーションマネージャーの利用確認
    if ([CLLocationManager locationServicesEnabled]) {
        
        //デリゲートを設定
		self.locationManager.delegate = self;
        
		// 位置情報取得開始
		[_locationManager startUpdatingLocation];
        
	}else{
        
        //　位置情報が使えない場合はエラーを返す
        NSLog(@"位置情報使えないよ><");
    }
    
    mapView.showsUserLocation = YES;
    mapView.userLocation.title = @"現在地";
    mapFlag = YES;
    
    //ロケーションマネージャーメソッドの起動
    [self locationManager];


    
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES]; // ナビゲーションバー表示
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // ナビゲーションバー非表示
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//経度緯度を参照（位置情報の取得）し、目的地までのルートを表示する
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    if (mapFlag == YES) {
        mapFlag = NO;
    
    //appデリゲートに接続
    AppDelegate *ap = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    //リストの中から1店舗の情報をランダムで取得する
    _yokado = [self getRandomFromList:ap.yokadoList];

    //現在の緯度と経度を取得
    CLLocation *location = locations[(locations.count-1)];
    CLLocationCoordinate2D latlng = location.coordinate;
    NSLog(@" %f , %f ",latlng.latitude,latlng.longitude);
    
    //マップ上にあるすべてのピンを削除
    [mapView removeAnnotations:mapView.annotations];
    
    //緯度と経度を取得し続けるため、取得の停止
    [self.locationManager stopUpdatingLocation];
    
    
//経路表示
    // 現在地
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(latlng.latitude, latlng.longitude);
    
    
    // 目的地（ヨーカドー）
    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(_yokado.latitude.floatValue, _yokado.longitude.floatValue);
    
    //ログに緯度、経度を吐き出し（後々に削除？）
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
         //エラーの場合は何もせずリターン
         if (error) return;
         
         //ルート上の数の確認
         if ([response.routes count] > 0)
         {
             //最初のルートを引っ張っているようです。
             MKRoute *route = (response.routes)[0];
             
             //目的地の情報をログに吐き出し（後ほど削除？）
             NSLog(@"distance: %.2f meter", route.distance);
             
             // 地図上にルートを描画
             [self.mapView addOverlay:route.polyline];
             
             //目的地にピンを刺す
             NSString *title = _yokado.name;
             CustomAnnotation *customAnnotation = [[CustomAnnotation alloc] initWithCoordinates:toCoordinate newTitle:title newSubTitle:nil];
             
             //カスタムアノテーションをaddする
             [mapView addAnnotation:customAnnotation];
             
             
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
             
             
             //ラベルを挿入する場合はtitleViewに挿入
             self.navigationItem.titleView = titleLabel;
    /*ナビゲーションバーのタイトル設定おわり*/
             
             
             
             
             //ピンの表示領域の設定
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
             MKCoordinateSpan span = MKCoordinateSpanMake((maxLat - minLat) * 2, (maxLng - minLng) * 2);
             MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
             [mapView setRegion:[mapView regionThatFits:region] animated:YES];
             
                //マップに表示する
             [self.view addSubview:self.mapView];
             
             
         }
     }];
    }
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



#pragma - mapkit delegate

// ViewController.mファイル内にviewForAnnotation関数を記述
-(MKAnnotationView*)mapView:(MKMapView*)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // ①ユーザの現在地はデフォルトの青丸マークを使いたいのでreturn: nil
    if (annotation == mapView.userLocation) {
        return nil;
    } else {
        MKAnnotationView *annotationView;
        // ②再利用可能なannotationがあるかどうかを判断するための識別子を定義
        NSString* identifier = @"Pin";
        // ③dequeueReusableAnnotationViewWithIdentifierで"Pin"という識別子の使いまわせるannotationがあるかチェック
        annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        // ④使い回しができるannotationがない場合、annotationの初期化
        if(annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        // ⑤好きな画像をannotationとして設定
        annotationView.image = [UIImage imageNamed:@"flag.png"];
        annotationView.canShowCallout = YES;  // この設定で吹き出しが出る
        annotationView.annotation = annotation;
        annotationView.centerOffset = CGPointMake(0, -43);
        return annotationView;
    }
}

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
