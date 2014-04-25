//
//  ViewController.m
//  MySecondApp
//
//  Created by 新井脩司 on 2014/03/25.
//  Copyright (c) 2014年 sacrew. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *yokadoLogo;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//押した際にロゴが変わる
- (IBAction)LogoChange:(id)sender {
    UIImage *image = [UIImage imageNamed:@"tap_yokado_logo.jpg"];
    _yokadoLogo.image = image;
}

//ボタン内で指を離した際にロゴがもとに戻る(ストーリーボードで画面遷移)
- (IBAction)tapLogo:(id)sender {
    UIImage *image = [UIImage imageNamed:@"yokado_logo.jpg"];
    _yokadoLogo.image = image;
    
}

//ロゴの外で指を離した際にロゴがもとに戻る
- (IBAction)cancelLogo:(id)sender {
    UIImage *image = [UIImage imageNamed:@"yokado_logo.jpg"];
    _yokadoLogo.image = image;

}



@end
