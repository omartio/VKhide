//
//  FriendsStore.h
//  VKhide
//
//  Created by Михаил Лукьянов on 05.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VKSdk.h>
#import "Friend.h"

@interface FriendsStore : NSObject

@property (strong, nonatomic) NSMutableArray *allFriends;
@property (strong, nonatomic) NSMutableArray *favFriendsIDs;

@property (readwrite, nonatomic) NSArray *searchResults;

+ (instancetype)sharedStore;

- (void)updateFriendsListForTableView:(UITableViewController *)tvc;
- (void)saveFavFriends;

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;

@end
