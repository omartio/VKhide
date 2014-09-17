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

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
    _adBanner.delegate = self;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil)
        {
            [self.view addSubview:_adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        
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
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        
        [UIView commitAnimations];
        
        _bannerIsVisible = NO;
    }
}

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
        
        [self.profileButton.imageView setImageWithURL:[NSURL URLWithString: avaUrl] placeholderImage:[UIImage imageNamed:@"no_avatar.png"]];
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
    
    NSMutableString *favIDs = [NSMutableString stringWithString:@""];
    for (NSString *uid in [[FriendsStore sharedStore] favFriendsIDs])
        [favIDs appendString:[NSString stringWithFormat:@"%@,", uid]];
    
    VKRequest * userReq = [[VKApi users] get:@{VK_API_USER_IDS: favIDs, VK_API_FIELDS: @"photo_max, last_seen, timezone, online"}];
    
    [userReq executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"%@", response.json);
        self.favFriends = [NSMutableArray arrayWithArray:response.json];
        [self.favFriendCollectionView reloadData];
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
    
    [cell.avaImg setImageWithURL:[NSURL URLWithString:friend[@"photo_max"]] placeholderImage:[UIImage imageNamed:@"no_avatar.png"]];
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
    FavFrinedTableViewController *fftvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FavFrinedTableViewController"];
    fftvc.favID = indexPath.item;
    [self.navigationController pushViewController:fftvc animated:YES];
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
