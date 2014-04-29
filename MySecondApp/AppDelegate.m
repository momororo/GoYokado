//
//  AppDelegate.m
//  MySecondApp
//
//  Created by 新井脩司 on 2014/03/25.
//  Copyright (c) 2014年 sacrew. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
        
        // CSVファイルからセクションデータを取得する
        NSString *csvFile = [[NSBundle mainBundle] pathForResource:@"yokadoList" ofType:@"csv"];
        NSLog(@"%@",csvFile);
        NSData *csvData = [NSData dataWithContentsOfFile:csvFile];
        NSString *csv = [[NSString alloc] initWithData:csvData encoding:NSUTF8StringEncoding];
        
        NSScanner *scanner = [NSScanner scannerWithString:csv];
        
        // 改行文字の選定
        NSCharacterSet *chSet = [NSCharacterSet newlineCharacterSet];
        NSString *line;
        
        // レコードを入れる NSMutableArray
        _yokadoList = [NSMutableArray array];
        
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
            
            [_yokadoList addObject:yokado];
            
            // 改行文字をスキップ
            [scanner scanCharactersFromSet:chSet intoString:NULL];
    }
    
    /*******************************************************
     CSVファイルからデータを引っ張るメソッド　おわり
     *******************************************************/

    
        return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
