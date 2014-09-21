//
//  Friend.m
//  VKhide
//
//  Created by Михаил Лукьянов on 05.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import "Friend.h"

@implementation Friend

-(id)initWithID:(NSString *)uid FirstName:(NSString *)fName lastName:(NSString *)lName sex:(NSString *)sex lastSeen:(NSString *)ls avaUrl:(NSString *)url online:(BOOL)online mobile:(BOOL)mobile
{
    self = [super init];
    
    self.id_user = uid;
    self.first_name = fName;
    self.last_name = lName;
    self.sex = sex;
    self.name = [NSString stringWithFormat:@"%@ %@", fName, lName];
    self.last_seen = ls;
    self.ava_url = url;
    self.online = online;
    self.mobile = mobile;
    
    return self;
}

+(id)FrinedWithID:(NSString *)uid FirstName:(NSString *)fName lastName:(NSString *)lName avaUrl:(NSString *)url
{
    Friend *friend = [[self alloc] init];
    friend.id_user = uid;
    friend.first_name = fName;
    friend.last_name = lName;
    friend.ava_url = url;
    return friend;
}

+(id)FriendWithID:(NSString *)uid
{
    Friend *friend = [[self alloc] init];
    friend.id_user = uid;
    return friend;
}

-(NSUInteger)hash
{
    return self.id_user.integerValue;
}

-(BOOL)isEqual:(id)object
{
    Friend *bFriend = object;
    return [self.id_user isEqualToString:bFriend.id_user];
}

@end
