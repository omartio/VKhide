//
//  User.h
//  VKhide
//
//  Created by Михаил Лукьянов on 05.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VKSdk.h>

@interface User : NSObject

+(instancetype)sharedUser;

@property (nonatomic) NSString* id_user;
@property (nonatomic) UIImage* userAva;

@end
