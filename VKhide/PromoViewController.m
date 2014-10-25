//
//  PromoViewController.m
//  VKhide
//
//  Created by Михаил Лукьянов on 24.10.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import "PromoViewController.h"
#import "User.h"

@interface PromoViewController ()

@end

@implementation PromoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openAppStore:(id)sender {
    [[User sharedUser] openProInAppStore];
}
- (IBAction)dissmisButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
