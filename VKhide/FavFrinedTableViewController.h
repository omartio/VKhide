//
//  FavFrinedTableViewController.h
//  VKhide
//
//  Created by Mikhail Lukyanov on 15.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavFrinedTableViewController : UITableViewController <UISearchDisplayDelegate, UITableViewDelegate>

@property (nonatomic) NSInteger favID;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *remomeButton;

@end
