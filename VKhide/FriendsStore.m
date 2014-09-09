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
        self.prefs = [NSUserDefaults standardUserDefaults];
        //[self.prefs removeObjectForKey:@"favFriends"];
        self.favFriendsIDs = [[NSMutableArray alloc] initWithArray:[self.prefs arrayForKey:@"favFriends"]];
    }
    
    return self;
}

-(void)saveFavFriends
{
    [self.prefs setObject:self.favFriendsIDs forKey:@"favFriends"];
    [self.prefs synchronize];
}

-(void)updateFriendsListForTableView:(UITableViewController *)tvc
{
    [[[FriendsStore sharedStore] allFriends] removeAllObjects];
    
    VKRequest * userReq = [[VKApi friends] get:@{VK_API_FIELDS: @"last_seen, online, photo_max, sex", VK_API_ORDER : @"hints"}];
    
    [userReq executeWithResultBlock:^(VKResponse * response) {
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
