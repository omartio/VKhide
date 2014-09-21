//
//  FriendsTableViewController.h
//  VKhide
//
//  Created by Михаил Лукьянов on 05.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>

@interface FriendsTableViewController : UITableViewController <UISearchDisplayDelegate, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *hideFavButtom;

@end
