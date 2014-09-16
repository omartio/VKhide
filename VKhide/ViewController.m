//
//  ViewController.m
//  VKhide
//
//  Created by Михаил Лукьянов on 02.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

static NSString *const NEXT_CONTROLLER_SEGUE_ID = @"START_WORK";
static NSArray  * SCOPE = nil;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    SCOPE = @[VK_PER_WALL, VK_PER_FRIENDS, VK_PER_GROUPS, VK_PER_NOHTTPS];
	[super viewDidLoad];
    
	[VKSdk initializeWithDelegate:self andAppId:@"4442573"];
    
    if ([VKSdk wakeUpSession])
    {
        [self startWorking];
    }
    else
    {
        [self authorize:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startWorking {
    
    [self performSegueWithIdentifier:NEXT_CONTROLLER_SEGUE_ID sender:self];
}

- (IBAction)authorize:(id)sender {
	[VKSdk authorize:SCOPE revokeAccess:YES];
}

- (IBAction)authorizeForceOAuth:(id)sender {
	[VKSdk authorize:SCOPE revokeAccess:YES forceOAuth:YES];
}

- (IBAction)authorizeForceOAuthInApp:(id)sender {
	[VKSdk authorize:SCOPE revokeAccess:YES forceOAuth:YES inApp:YES display:VK_DISPLAY_IOS];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
	VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
	[vc presentIn:self];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
	[self authorize:nil];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self startWorking];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
	[self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    [self startWorking];
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
	[[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)vkSdkRenewedToken:(VKAccessToken *)newToken
{
    [self startWorking];
}


@end
