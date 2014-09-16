//
//  SearchUserViewController.m
//  VKhide
//
//  Created by Mikhail Lukyanov on 10.09.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import "SearchUserViewController.h"
#import <VKApi.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "Friend.h"
#import "FriendsStore.h"

@interface SearchUserViewController ()

@property (nonatomic, strong) NSArray *results;

@end

@implementation SearchUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCell"];
    }
    
    Friend *friend = self.results[indexPath.row];
    
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", friend.first_name, friend.last_name];
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:friend.ava_url] placeholderImage:[UIImage imageNamed:@"no_avatar.png"]];

    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 0;
    cell.imageView.layer.cornerRadius = 32; //cell.imageView.frame.size.height / 2.0;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.addButton setEnabled:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *fString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (fString.length % 3 == 0)
    {
        [self searchUser:fString type:[self.typePicker selectedSegmentIndex]];
    }
    return YES;
}

//Нажата кнопка добавить
-(IBAction)addButtonTapped:(id)sender
{
    NSInteger row = [self.tableView indexPathForSelectedRow].row;
    [[FriendsStore sharedStore] addAdditionalUsers:self.results[row]];
    [self.navigationController popViewControllerAnimated:YES];
}

//Нажата кнопка найти
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchButtonTapped:nil];
    return YES;
}

//Нажата кнопка найти
-(IBAction)searchButtonTapped:(id)sender
{
    [self.searchTextField resignFirstResponder];
    [self searchUser:self.searchTextField.text type:[self.typePicker selectedSegmentIndex]];
}

//Ищет по запросу и загружает результат в таблицу
-(void)searchUser:(NSString *)query type:(NSInteger)type
{
    if (query.length == 0)
        return;
    //Наводим красоту
    [self.searchButton setTitle:@"" forState:UIControlStateNormal];
    [self.spinner startAnimating];
    self.results = nil;
    [self.tableView reloadData];
    
    if (type < 1)
    {
        VKRequest * userReq = [[VKApi users] get:@{VK_API_USER_IDS: query, VK_API_FIELDS: @"photo_max"}];
        [userReq executeWithResultBlock:^(VKResponse *response) {
            NSLog(@"%@", response.json);
            self.results = [NSArray arrayWithObjects:[Friend FrinedWithID:response.json[0][@"id"] FirstName:response.json[0][@"first_name"] lastName:response.json[0][@"last_name"] avaUrl:response.json[0][@"photo_max"]], nil];
            [self searchEnd];
        } errorBlock:^(NSError *error) {
            NSLog(@"%@", error);
            self.results = nil;
            [self searchEnd];
        }];
    }
    else
    {
        VKRequest * userReq = [VKApi requestWithMethod:@"search.getHints" andParameters:@{@"q" : query, @"filters" : @"idols,correspondents,mutual_friends", @"limit" : @"20", VK_API_FIELDS: @"photo_max"} andHttpMethod:@"POST"];
        [userReq executeWithResultBlock:^(VKResponse *response) {
            NSLog(@"%@", response.json);
            NSMutableArray *mres = [[NSMutableArray alloc] init];
            for (id cuser in response.json) {
                if ([cuser[@"type"] isEqualToString:@"profile"])
                    [mres addObject:[Friend FrinedWithID:cuser[@"profile"][@"id"] FirstName:cuser[@"profile"][@"first_name"] lastName:cuser[@"profile"][@"last_name"] avaUrl:cuser[@"profile"][@"photo_max"]]];
            }
            self.results = mres;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self searchEnd];
            });
            
        } errorBlock:^(NSError *error) {
            NSLog(@"%@", error);
            self.results = nil;
            [self searchEnd];
        }];
    }
}

//Поиск закончен
-(void)searchEnd
{
    [self.tableView reloadData];
    [self.spinner stopAnimating];
    [self.searchButton setTitle:@"Найти" forState:UIControlStateNormal];
    [self.addButton setEnabled:NO];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
