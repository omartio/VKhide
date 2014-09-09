//
//  Friend.h
//  VKhide
//
//  Created by Михаил Лукьянов on 05.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VKSdk.h>

@interface Friend : NSObject

@property (nonatomic, strong) NSString *id_user;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *sex;


@property (nonatomic, strong) NSString *last_seen;
@property (nonatomic, strong) NSString *ava_url;
@property (nonatomic) BOOL online;
@property (nonatomic) BOOL mobile;

-(id)initWithID:(NSString *)uid FirstName:(NSString *)fName lastName:(NSString *)lName sex:(NSString *)sex lastSeen:(NSString *)ls avaUrl:(NSString *)url online:(BOOL)online mobile:(BOOL)mobile;
//-(id)initWithID:(NSString *)uid;

@end
