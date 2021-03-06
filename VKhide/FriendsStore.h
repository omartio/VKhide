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
@property (strong, nonatomic) NSMutableArray *hiddenFriends;
@property (strong, nonatomic) NSMutableArray *additionalUsers; //Самостоятельно добавленные юзеры (их id_vk)
@property (nonatomic) NSInteger *additionalUsersNonHidenCount; //Самостоятельно добавленные юзеры (их id_vk)


@property (readwrite, nonatomic) NSArray *searchResults;

+ (instancetype)sharedStore;

- (void)updateFriendsListForTableView:(UITableViewController *)tvc;
- (void)saveFavFriends;
- (void)addFavFriendsIDs:(NSString *)id_user;

- (BOOL)userIsInList:(NSString *)id_user;
- (BOOL)userIsFavorite:(NSString *)id_user;

- (void)saveAddFriends;
- (void)addAdditionalUsers:(Friend *)user;
- (void)deleteAdditionalUserWithIndexInArray:(NSInteger)index;

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;


@end
