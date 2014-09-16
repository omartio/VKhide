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

@interface MainViewController ()

@end

@implementation MainViewController
{
    NSString *mintAgo, *directTime;
    BOOL ago, online;
    BOOL favDirect;
    NSArray *favAvas;
    NSArray *favNames;
    NSArray *favButtons;
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
    
    CALayer* lr = [self.avaImg layer];
    [lr setMasksToBounds:YES];
    [lr setCornerRadius:self.avaImg.frame.size.height / 2.0];
    [lr setBorderWidth:2];
    [lr setBorderColor:[[UIColor whiteColor] CGColor]];
    
    favAvas = [[NSArray alloc] initWithObjects:self.favAva1, self.favAva2, self.favAva3, nil];
    favNames = [[NSArray alloc] initWithObjects:self.favName1, self.favName2, self.favName3, nil];
    favButtons = [[NSArray alloc] initWithObjects:self.favButton1, self.favButton2, self.favButton3, nil];
    
    for (int i = 0; i < 3; i ++)
    {
                /*
        lr = [favAvas[i] layer];
        [lr setMasksToBounds:YES];
        [lr setCornerRadius:((UIImageView *)favAvas[i]).frame.size.height / 2.0];
        [lr setBorderWidth:0];
         */
    }
    
    [self makeRectangleCorners:self.nameLabel.layer];
    [self makeRectangleCorners:self.frindButton.layer];
    [self makeRectangleCorners:self.lastseenBG.layer];
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
        
        [self.avaImg setImageWithURL:[NSURL URLWithString: avaUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [UIView animateWithDuration:0.5 animations:^{
                self.avaImg.alpha = 1.0;
            }];
        }];
        
        //Name
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", response.json[0][@"first_name"], response.json[0][@"last_name"]];
        
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

    if ([[[FriendsStore sharedStore] favFriendsIDs] count] < 3)
    {
        for (int i = (int)[[[FriendsStore sharedStore] favFriendsIDs] count]+1; i < 3; i++)
        {
            ((UIImageView *)favAvas[i]).hidden = YES;
            ((UILabel *)favNames[i]).text = @"";
            ((UIButton *)favButtons[i]).enabled = NO;
        }
        
        NSInteger last = (int)[[[FriendsStore sharedStore] favFriendsIDs] count];
        ((UIImageView *)favAvas[last]).image = [UIImage imageNamed:@"add_inv.png"];
        ((UIImageView *)favAvas[last]).alpha = 0.5f;
        ((UIImageView *)favAvas[last]).hidden = NO;
        ((UILabel *)favNames[last]).text = @"";
        ((UIButton *)favButtons[last]).enabled = YES;
    }
    
    if ([[[FriendsStore sharedStore] favFriendsIDs] count] == 0)
        return;
    
    
    NSMutableString *favIDs = [NSMutableString stringWithString:@""];
    for (NSString *uid in [[FriendsStore sharedStore] favFriendsIDs])
        [favIDs appendString:[NSString stringWithFormat:@"%@,", uid]];
    
    VKRequest * userReq = [[VKApi users] get:@{VK_API_USER_IDS: favIDs, VK_API_FIELDS: @"photo_max, last_seen, timezone, online"}];
    
    [userReq executeWithResultBlock:^(VKResponse * response) {
        NSLog(@"%@", response.json);
        
        for (int i = 0; i < [[[FriendsStore sharedStore] favFriendsIDs] count]; i++)
        {
            UIImageView *currentFavAva = ((UIImageView *)favAvas[i]);
            
            [currentFavAva setImageWithURL:[NSURL URLWithString:response.json[i][@"photo_max"]]
                           placeholderImage:[UIImage imageNamed:@"no_avatar.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               currentFavAva.image = [self image:currentFavAva.image makeRoundCornersWithRadius:((UIImageView *)favAvas[i]).frame.size.height];
                               if (((((NSString *) response.json[i][@"online_mobile"]).intValue == 1) || ((NSString *)response.json[i][@"last_seen"][@"platform"]).intValue < 7))
                                   currentFavAva.image = [self drawImage:currentFavAva.image withBadge:[UIImage imageNamed:@"mobile.png"]];
                           }];
            
            currentFavAva.hidden = NO;
            currentFavAva.alpha = 1.0;
            ((UIButton *)favButtons[i]).enabled = YES;
            
            //Online
            online = ((NSString *) response.json[i][@"online"]).intValue == 1;
            if (online)
            {
                ((UILabel *)favNames[i]).text = @"В сети";
            }
            else
            {
            ((UILabel *)favNames[i]).text = [NSDate lastseenTimestapm:response.json[i][@"last_seen"][@"time"] directTime:favDirect];
            }
            
            
            
            /*NIAttributedLabel *label = favNames[i];
            if (((((NSString *) response.json[i][@"online_mobile"]).intValue == 1) || ((NSString *)response.json[i][@"last_seen"][@"platform"]).intValue < 7))
                [label insertImage:[UIImage imageNamed:@"mobile.png"] atIndex:0];*/
        }
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];

}

-(UIImage *)drawImage:(UIImage*)profileImage withBadge:(UIImage *)badge
{
    UIGraphicsBeginImageContextWithOptions(profileImage.size, NO, 0.0f);
    [profileImage drawInRect:CGRectMake(0, 0, profileImage.size.width, profileImage.size.height)];
    [badge drawInRect:CGRectMake(profileImage.size.width - badge.size.width, profileImage.size.height - badge.size.height, badge.size.width, badge.size.height)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

-(UIImage*)image:(UIImage *)image makeRoundCornersWithRadius:(const CGFloat)RADIUS {
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    const CGRect RECT = CGRectMake(0, 0, image.size.width, image.size.height);
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:RECT cornerRadius:RADIUS] addClip];
    // Draw your image
    [image drawInRect:RECT];
    
    // Get the image, here setting the UIImageView image
    //imageView.image
    UIImage* imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imageNew;
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"FAV1"])
    {
        ((FavFrinedTableViewController *) segue.destinationViewController).favID = 0;
    }
    if ([segue.identifier isEqualToString:@"FAV2"])
    {
        ((FavFrinedTableViewController *) segue.destinationViewController).favID = 1;
    }
    if ([segue.identifier isEqualToString:@"FAV3"])
    {
        ((FavFrinedTableViewController *) segue.destinationViewController).favID = 2;
    }
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self)
    {
        [self updateLastSeen:nil];
    }
}

@end
