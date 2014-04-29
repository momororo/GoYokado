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

@interface MapViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray    *yokadoList;
@property (strong, nonatomic) Yokado *yokado;
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

    
    //ヨーカドーのリストを生成
    NSMutableArray *yokadoList = [self getDataFromCSV:@"yokadoList"];
    
    //リストの中から1店舗の情報をランダムで取得する
    _yokado = [self getRandomFromList:yokadoList];
    

    // ロケーションマネージャーを作成
	self.locationManager = CLLocationManager.new;
    if ([CLLocationManager locationServicesEnabled]) {
		self.locationManager.delegate = self;
		// 位置情報取得開始
		[_locationManager startUpdatingLocation];
	}else{
        NSLog(@"位置情報使えないよ><");
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
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
    //現在の緯度と経度を取得
    CLLocation *location = [locations objectAtIndex:(locations.count-1)];
    CLLocationCoordinate2D latlng = location.coordinate;
    NSLog(@" %f , %f ",latlng.latitude,latlng.longitude);
    
    //500mスクウェアで領域を生成
    MKCoordinateRegion reg = MKCoordinateRegionMakeWithDistance(latlng, 13500, 13500);
    _mapView.region = reg;
    
    //アノテーション(ピン)を生成し、表示
    MKPointAnnotation *ann = MKPointAnnotation.new;
    ann.coordinate = latlng;
    ann.title = @"現在地";
    [_mapView removeAnnotations:_mapView.annotations];          //マップ上にあるすべてのピンを削除
    [_mapView addAnnotation:ann];
    
    //緯度と経度を取得し続けるため、取得の停止
    [self.locationManager stopUpdatingLocation];
    
    
//経路表示
    // 現在地
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(latlng.latitude, latlng.longitude);
    
    
    // 目的地（ヨーカドー）
    CLLocationCoordinate2D toCoordinate = CLLocationCoordinate2DMake(_yokado.latitude.intValue, _yokado.longitude.intValue);
    
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
             MKRoute *route = [response.routes objectAtIndex:0];
             NSLog(@"distance: %.2f meter", route.distance);
             
             // 地図上にルートを描画
             [self.mapView addOverlay:route.polyline];
             
             //目的地にピンを刺す
             MKPointAnnotation *spot = MKPointAnnotation.new;
             spot.coordinate = toCoordinate;
             spot.title = _yokado.name;
             [_mapView addAnnotation:spot];
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






/*******************************************************
 CSVファイルからデータを引っ張るメソッド
 http://snippets.feb19.jp/?p=942
 から取得
 
 引数にファイルネームを指定すると
 csvを配列形式で返してくれるようである。
*******************************************************/
- (NSMutableArray *)getDataFromCSV:(NSString *)csvFileName
{
    

    // CSVファイルからセクションデータを取得する
    NSString *csvFile = [[NSBundle mainBundle] pathForResource:csvFileName ofType:@"csv"];
    NSLog(@"%@",csvFile);
    NSData *csvData = [NSData dataWithContentsOfFile:csvFile];
    NSString *csv = [[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding];
    
    NSScanner *scanner = [NSScanner scannerWithString:csv];

    // 改行文字の選定
    NSCharacterSet *chSet = [NSCharacterSet newlineCharacterSet];
    NSString *line;
    
    // レコードを入れる NSMutableArray
    NSMutableArray *yokadoList = [NSMutableArray array];
    
    while (![scanner isAtEnd]) {
        
        // 一行づつ読み込んでいく
        [scanner scanUpToCharactersFromSet:chSet intoString:&line];
        NSArray *array = [line componentsSeparatedByString:@","];
        
        //ヨーカドーオブジェクトに挿入
        Yokado *yokado = [Yokado new];
        yokado.name = array[0];
        yokado.address = array[1];
        yokado.latitude = array[2];
        yokado.longitude = array[3];
        
        [yokadoList addObject:yokado];
        
        // 改行文字をスキップ
        [scanner scanCharactersFromSet:chSet intoString:NULL];
    }
    return yokadoList;
}

/*******************************************************
 CSVファイルからデータを引っ張るメソッド　おわり
*******************************************************/



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
