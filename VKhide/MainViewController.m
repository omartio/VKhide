//
//  MainViewController.m
//  VKhide
//
//  Created by Михаил Лукьянов on 04.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import "MainViewController.h"
#import "User.h"
#import "NSDate+Utilities.h"
#import "FriendsStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FavFrinedTableViewController.h"
#import "FavFriendCell.h"
#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "GADRequest.h"

@interface MainViewController ()

@property (nonatomic, strong) NSMutableArray *favFriends;

@end

@implementation MainViewController
{
    NSString *mintAgo, *directTime;
    BOOL ago, online;
    BOOL favDirect;
    NSArray *favAvas;
    NSArray *favNames;
    NSArray *favButtons;
    
    BOOL _bannerIsVisible;
    ADBannerView *_adBanner;
    
    GADBannerView *_bannerView;
}

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
    self.navigationController.delegate = self;
    // Do any additional setup after loading the view.
    [User sharedUser];
    
    [self loadAva];
    ago = YES;
    favDirect = NO;
    [self updateLastSeen:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(updateLastSeen:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    //круглая аватарка
    CALayer* lr = [self.avaImg layer];
    [lr setMasksToBounds:YES];
    [lr setCornerRadius:self.avaImg.frame.size.height / 2.0];
    [lr setBorderWidth:2];
    [lr setBorderColor:[[UIColor whiteColor] CGColor]];
    
    //Закругляем кнопки
    [self makeRectangleCorners:self.nameLabel.layer];
    [self makeRectangleCorners:self.frindButton.layer];
    [self makeRectangleCorners:self.lastseenBG.layer];
    
    self.adSelfBanner.hidden = YES;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
    _adBanner.delegate = self;
    
    
    _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    // Replace this ad unit ID with your own ad unit ID.
    _bannerView.adUnitID = @"ca-app-pub-3244156087014337/1126778805";
    _bannerView.rootViewController = self;
    
    _bannerView.frame = CGRectMake(0, self.view.frame.size.height - _bannerView.frame.size.height, _bannerView.frame.size.width, _bannerView.frame.size.height);
    
}

#pragma mark Ad

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.adSelfBanner.hidden = YES;
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self.view addSubview:_adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectMake(0, self.view.frame.size.height - banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);// CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Failed to retrieve ad");
    
    if (_bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectMake(0, self.view.frame.size.height + banner.frame.size.height, banner.frame.size.width, banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
    
    [self.view addSubview:_bannerView];
    
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made.
    //request.testDevices = @[@"e17b6ef2942389e7cec693df27475d0e"];
    
    VKRequest * userReq = [[VKApi users] get:@{VK_API_FIELDS: @"sex, bdate"}];
    
    [userReq executeWithResultBlock:^(VKResponse * response) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"d.MM.yyyy"];
        NSDate *bdate = [df dateFromString:(NSString *)response.json[0][@"bdate"]];
        request.birthday = bdate;
        request.gender = ((NSString *)response.json[0][@"sex"]).intValue == 2 ? kGADGenderMale : kGADGenderFemale;
        //NSLog(@"%@", request);
        //NSLog(@"%@", response.json);
        [_bannerView loadRequest:request];
    }
                         errorBlock:^(NSError * error) {
                             if (error.code != VK_API_ERROR) {
                                 [error.vkError.request repeat];
                             } else {
                                 NSLog(@"VK error: %@", error);
                                 [_bannerView loadRequest:request];
                             }
                         }];

    _adBanner.delegate = nil;
}

/*
- (IBAction)selfAdTapped:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/gravity-w4lls/id941154308"];
    [[UIApplication sharedApplication] openURL:url];
}
*/

#pragma VK Api

-(void)makeRectangleCorners:(CALayer *)layer
{
    
    layer.cornerRadius = 10;
    layer.borderWidth = 0;
    layer.masksToBounds = YES;
}

-(void)loadAva
{
    VKRequest * userReq = [[VKApi users] get:@{VK_API_FIELDS: @"photo_max"}];
    
    [userReq executeWithResultBlock:^(VKResponse * response) {
        //Ava
        NSString *avaUrl = response.json[0][@"photo_max"];
        
        [self.profileButton.imageView sd_setImageWithURL:[NSURL URLWithString: avaUrl] placeholderImage:[UIImage imageNamed:@"no_avatar.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.profileButton setImage:image forState:UIControlStateNormal];
        }];
        CALayer* lr = [self.profileButton.imageView layer];
        [lr setMasksToBounds:YES];
        [lr setCornerRadius:self.profileButton.imageView.frame.size.height / 2.0];
        [lr setBorderWidth:0];
        [lr setBorderColor:[[UIColor whiteColor] CGColor]];
        
        //Name
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", response.json[0][@"first_name"], response.json[0][@"last_name"]];
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];

}

-(IBAction)updateLastSeen:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            [self.lastseenSpin startAnimating];
            self.lastseenLabel.alpha = 0;
        }];
    });
    VKRequest * userReq = [[VKApi users] get:@{VK_API_FIELDS: @"last_seen, timezone, online"}];
    
    [userReq executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"%@", response.json);
        
        //Online
        online = ((NSString *) response.json[0][@"online"]).intValue == 1;
        
        if (online)
        {
            self.messageLabel.text = @"";
            self.lastseenLabel.text = @"Вы в сети";
            [self.lastseenSpin stopAnimating];
        }
        else
        {
            self.messageLabel.text = @"Вы были в сети";
            self.lastseenLabel.text = [NSDate lastseenTimestapm:response.json[0][@"last_seen"][@"time"] directTime:!ago];
        }
        NSString *mob = ((((NSString *) response.json[0][@"online_mobile"]).intValue == 1) || ((NSString *)response.json[0][@"last_seen"][@"platform"]).intValue < 7) ? @" (моб.)" : @"";
        self.lastseenLabel.text = [self.lastseenLabel.text stringByAppendingString:mob];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                [self.lastseenSpin stopAnimating];
                self.lastseenLabel.alpha = 1;
            }];
        });
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];
    [self updateFav:nil];
}

-(IBAction)updateFav:(id)sender
{
    if ([[[FriendsStore sharedStore] favFriendsIDs] count] == 0)
        return;
    
    NSArray *visCells = [self.favFriendCollectionView visibleCells];
    for (FavFriendCell *cell in visCells)
    {
        cell.titelLabel.hidden = YES;
    }
    
    NSMutableString *favIDs = [NSMutableString stringWithString:@""];
    for (NSString *uid in [[FriendsStore sharedStore] favFriendsIDs])
        [favIDs appendString:[NSString stringWithFormat:@"%@,", uid]];
    
    VKRequest * userReq = [[VKApi users] get:@{VK_API_USER_IDS: favIDs, VK_API_FIELDS: @"photo_max, last_seen, timezone, online"}];
    
    [userReq executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"%@", response.json);
        self.favFriends = [NSMutableArray arrayWithArray:response.json];
        [self.favFriendCollectionView reloadData];
        for (FavFriendCell *cell in visCells)
        {
            cell.titelLabel.hidden = NO;
        }

    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];

}

-(IBAction)changeLastSeen:(id)sender
{
    ago = !ago;
    [self updateLastSeen:nil];
    
}

-(IBAction)changeLastSeenFav:(id)sender
{
    favDirect = !favDirect;
    [self updateFav:nil];
}

-(IBAction)setOffline:(id)sender
{
    VKRequest * setOfflien = [VKRequest requestWithMethod:@"account.setOffline" andParameters:@{} andHttpMethod:@"GET"];
    
    [setOfflien executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"%@", response.json);
        self.offlineButton.hidden = YES;
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];
}

- (IBAction)logout:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Выйти?" message:@"Вы действительно хотите выйти из приложения?" delegate:self cancelButtonTitle:@"Нет" otherButtonTitles:@"Да", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [VKSdk forceLogout];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FavFriendCollectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[FriendsStore sharedStore] favFriendsIDs] count] + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FavFriendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FavFriendCell" forIndexPath:indexPath];
    
    //кнопка Добавить
    if (indexPath.item == [[[FriendsStore sharedStore] favFriendsIDs] count])
    {
        cell.avaImg.image = [UIImage imageNamed:@"add_inv"];
        cell.mobileImg.hidden = YES;
        cell.titelLabel.text = @"";
        cell.avaImg.layer.borderWidth = 0;
        
        return cell;
    }
    
    //Отоброжение друга
    id friend = self.favFriends[indexPath.item];
    
    [cell.avaImg sd_setImageWithURL:[NSURL URLWithString:friend[@"photo_max"]] placeholderImage:[UIImage imageNamed:@"no_avatar.png"]];
    cell.mobileImg.hidden = !(((((NSString *) friend[@"online_mobile"]).intValue == 1) || ((NSString *)friend[@"last_seen"][@"platform"]).intValue < 7));
    cell.avaImg.layer.masksToBounds = YES;
    cell.avaImg.layer.borderColor = [[UIColor whiteColor] CGColor];
    cell.avaImg.layer.borderWidth = 2;
    cell.avaImg.layer.cornerRadius = cell.avaImg.frame.size.height / 2.0;
    
    
    //Online
    online = ((NSString *) friend[@"online"]).intValue == 1;
    if (online)
    {
        cell.titelLabel.text = @"В сети";
    }
    else
    {
        cell.titelLabel.text = [NSDate lastseenTimestapm:friend[@"last_seen"][@"time"] directTime:favDirect];
    }
    
    if (friend == nil)
        cell.titelLabel.text = @"...";
    

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //LITE
    if (indexPath.item >= 3)
    {
        UIViewController *promoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PromoViewController"];
        [self.navigationController presentViewController:promoVC animated:YES completion:nil];
        return;
    }
    //////
    
    FavFrinedTableViewController *fftvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FavFrinedTableViewController"];
    fftvc.favID = indexPath.item;
    [self.navigationController pushViewController:fftvc animated:YES];
}

-(BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == [[[FriendsStore sharedStore] favFriendsIDs] count])
    {
        return NO;
    }
    return YES;
}

-(BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    return toIndexPath.item < [[[FriendsStore sharedStore] favFriendsIDs] count];
}

-(void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    id favFriend = [[[FriendsStore sharedStore] favFriendsIDs] objectAtIndex:fromIndexPath.item];
    [[[FriendsStore sharedStore] favFriendsIDs] removeObjectAtIndex:fromIndexPath.item];
    [[[FriendsStore sharedStore] favFriendsIDs] insertObject:favFriend atIndex:toIndexPath.item];
    [[FriendsStore sharedStore] saveFavFriends];
    
    id object = self.favFriends[fromIndexPath.item];
    [self.favFriends removeObjectAtIndex:fromIndexPath.item];
    [self.favFriends insertObject:object atIndex:toIndexPath.item];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self)
    {
        [self updateLastSeen:nil];
    }
}

@end
