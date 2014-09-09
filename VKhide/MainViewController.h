//
//  MainViewController.h
//  VKhide
//
//  Created by Михаил Лукьянов on 04.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VKSdk.h>
#import <NGAParallaxMotion.h>
#import <NIAttributedLabel.h>

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avaImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastseenLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *avaSpin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *lastseenSpin;
@property (weak, nonatomic) IBOutlet UIButton *offlineButton;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIButton *frindButton;
@property (weak, nonatomic) IBOutlet UIButton *lastseenBG;


@property (weak, nonatomic) IBOutlet UIImageView *favAva1;
@property (weak, nonatomic) IBOutlet UIImageView *favAva2;
@property (weak, nonatomic) IBOutlet UIImageView *favAva3;

@property (weak, nonatomic) IBOutlet NIAttributedLabel *favName1;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *favName2;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *favName3;

@property (weak, nonatomic) IBOutlet UIButton *favButton1;
@property (weak, nonatomic) IBOutlet UIButton *favButton2;
@property (weak, nonatomic) IBOutlet UIButton *favButton3;

@end
