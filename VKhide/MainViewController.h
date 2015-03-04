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
#import <LXReorderableCollectionViewFlowLayout.h>
#import <iAd/iAd.h>

@class GADBannerView;

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout, ADBannerViewDelegate, UIGestureRecognizerDelegate>

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
@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@property (weak, nonatomic) IBOutlet UIView *adSelfBanner;

@property (weak, nonatomic) IBOutlet UICollectionView *favFriendCollectionView;

@end
