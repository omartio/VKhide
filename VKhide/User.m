//
//  User.m
//  VKhide
//
//  Created by Михаил Лукьянов on 05.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import "User.h"
#import "FriendsStore.h"

@implementation User

+(instancetype)sharedUser
{
    static User *sharedUser = nil;
    
    if (sharedUser.id_user == nil || !sharedUser)
    {
        sharedUser = [[self alloc] initPrivate];
    }
    
    return sharedUser;
}

-(instancetype)initPrivate
{
    self = [super init];
    
    self.id_user = [[VKSdk getAccessToken] userId];
    
    [FriendsStore sharedStore];
    
    return self;
}

-(void)openProInAppStore
{
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/ru/app/druz-a-onlajn-dla-vkontakte/id906358004?l=en&mt=8"];
    [[UIApplication sharedApplication] openURL:url];
}


@end
