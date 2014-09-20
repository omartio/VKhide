//
//  SearchUserViewController.h
//  VKhide
//
//  Created by Mikhail Lukyanov on 10.09.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchUserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *typePicker;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *addButton;


@end
