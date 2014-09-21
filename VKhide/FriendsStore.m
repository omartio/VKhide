//
//  FriendsStore.m
//  VKhide
//
//  Created by Михаил Лукьянов on 05.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import "FriendsStore.h"
#import "Friend.h"
#import "NSDate+Utilities.h"

@interface FriendsStore()

@property (nonatomic, strong) NSDate *lastRefresh;

@property (nonatomic, strong) NSUserDefaults *prefs;

@end

@implementation FriendsStore

+(instancetype)sharedStore
{
    static FriendsStore *sharedStore = nil;
    
    if (!sharedStore)
    {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

-(instancetype)initPrivate
{
    self = [super init];
    
    if (self)
    {
        _allFriends = [[NSMutableArray alloc] init];
        //_additionalUsers = [[NSMutableArray alloc] init];
        self.prefs = [NSUserDefaults standardUserDefaults];
        //[self.prefs removeObjectForKey:@"favFriends"];
        self.favFriendsIDs = [[NSMutableArray alloc] initWithArray:[self.prefs arrayForKey:@"favFriends"]];
        self.additionalUsers = [[NSMutableArray alloc] initWithArray:[self.prefs arrayForKey:@"additionalUsers"]];
    }
    
    return self;
}

-(void)saveFavFriends
{
    [self.prefs setObject:self.favFriendsIDs forKey:@"favFriends"];
    [self.prefs synchronize];
}

-(void)addFavFriendsIDs:(NSString *)id_user
{
    if ([self.favFriendsIDs indexOfObject:id_user] != NSNotFound)
        return;
    [self.favFriendsIDs addObject:id_user];
    [self saveFavFriends];
}

-(void)saveAddFriends
{
    [self.prefs setObject:self.additionalUsers forKey:@"additionalUsers"];
    [self.prefs synchronize];
}

-(void)addAdditionalUsers:(Friend *)user
{
    if ([self.additionalUsers indexOfObject:user.id_user] != NSNotFound)
        return;
    [self.additionalUsers addObject:user.id_user];
    [self saveAddFriends];
}

-(void)deleteAdditionalUserWithIndexInArray:(NSInteger)index
{
    [self.additionalUsers removeObjectAtIndex:self.additionalUsers.count - index - 1];
    [self.allFriends removeObjectAtIndex:index];
    [self saveAddFriends];
}

-(void)updateFriendsListForTableView:(UITableViewController *)tvc
{
    [[[FriendsStore sharedStore] allFriends] removeAllObjects];
    
    NSMutableString *ids_vk = [[NSMutableString alloc] initWithString:@""];
    for (NSString *user_id_vk in self.additionalUsers)
        [ids_vk appendString:[NSString stringWithFormat:@"%@,", user_id_vk]];
    //if ([ids_vk isEqualToString:@""])
      //  return;
    
    VKRequest *addUsersReq = [[VKApi users] get:@{VK_API_USER_IDS: ids_vk, VK_API_FIELDS: @"last_seen, online, photo_max, sex"}];
    VKRequest * userReq = [[VKApi friends] get:@{VK_API_FIELDS: @"last_seen, online, photo_max, sex", VK_API_ORDER : @"hints"}];
    
    [addUsersReq executeAfter:userReq withResultBlock:^(VKResponse *response)
     {
         NSLog(@"ADD_FRiENDs%@", response.json);
         NSInteger count = self.additionalUsers.count;
         for (int i = 0; i < count; i++) {
             Friend *friend =[[Friend alloc] initWithID: response.json[i][@"id"]
                                              FirstName: response.json[i][@"first_name"]
                                               lastName: response.json[i][@"last_name"]
                                                    sex: response.json[i][@"sex"]
                                               lastSeen: response.json[i][@"last_seen"][@"time"]
                                                 avaUrl: response.json[i][@"photo_max"]
                                                 online: (((NSString *) response.json[i][@"online"]).intValue == 1)
                                                 mobile: ((((NSString *) response.json[i][@"online_mobile"]).intValue == 1) || ((NSString *)response.json[i][@"last_seen"][@"platform"]).intValue < 7)
                              ];
             
             [[[FriendsStore sharedStore] allFriends] insertObject:friend atIndex:0];
         }
         
         self.lastRefresh = [NSDate date];
         NSString *lastUpdated = [NSString stringWithFormat:@"Последнее обновление: %@", [self.lastRefresh shortTimeString]];
         tvc.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
         
         [tvc.tableView reloadData];
         [tvc.refreshControl endRefreshing];
     } errorBlock:^(NSError *error) {
         if (error.code != VK_API_ERROR) {
             [error.vkError.request repeat];
         } else {
             NSLog(@"ADD FRIEND VK error: %@", error);
         }
     }];
    
    
    [userReq executeWithResultBlock:^(VKResponse *response) {
        //NSLog(@"%@", response.json);
        
        NSInteger count = ((NSString *) response.json[@"count"]).intValue;
        for (int i = 0; i < count; i++) {
            Friend *friend =[[Friend alloc] initWithID: response.json[@"items"][i][@"id"]
                                             FirstName: response.json[@"items"][i][@"first_name"]
                                              lastName: response.json[@"items"][i][@"last_name"]
                                                   sex: response.json[@"items"][i][@"sex"]
                                              lastSeen: response.json[@"items"][i][@"last_seen"][@"time"]
                                                avaUrl: response.json[@"items"][i][@"photo_max"]
                                                online: (((NSString *) response.json[@"items"][i][@"online"]).intValue == 1)
                                                mobile: ((((NSString *) response.json[@"items"][i][@"online_mobile"]).intValue == 1) || ((NSString *)response.json[@"items"][i][@"last_seen"][@"platform"]).intValue < 7)
                             ];
            
            [[[FriendsStore sharedStore] allFriends] addObject:friend];
        }
        
        self.lastRefresh = [NSDate date];
        NSString *lastUpdated = [NSString stringWithFormat:@"Последнее обновление: %@", [self.lastRefresh shortTimeString]];
        tvc.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        
        [tvc.tableView reloadData];
        [tvc.refreshControl endRefreshing];
         
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];
    
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"first_name BEGINSWITH[c] %@ || last_name BEGINSWITH[c] %@", searchText, searchText];
    self.searchResults = [self.allFriends filteredArrayUsingPredicate:resultPredicate];
    
}

@end
