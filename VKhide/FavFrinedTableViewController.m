//
//  FavFrinedTableViewController.m
//  VKhide
//
//  Created by Mikhail Lukyanov on 15.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import "FavFrinedTableViewController.h"
#import "Friend.h"
#import "FriendsStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface FavFrinedTableViewController ()

@end

@implementation FavFrinedTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[FriendsStore sharedStore] updateFriendsListForTableView:self];
    if ([[[FriendsStore sharedStore] favFriendsIDs] count] == self.favID) {
        
        self.remomeButton.enabled = NO;
    } else {
        
        self.remomeButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)removeFAvFriend:(id)sender
{
    [[[FriendsStore sharedStore] favFriendsIDs] removeObjectAtIndex:self.favID];
    [[FriendsStore sharedStore] saveFavFriends];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [[FriendsStore sharedStore] filterContentForSearchText:searchString
                                                     scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                                            objectAtIndex:[self.searchDisplayController.searchBar
                                                                           selectedScopeButtonIndex]]];
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [[[FriendsStore sharedStore] searchResults] count];
    }else{
        return [[[FriendsStore sharedStore] allFriends] count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FavFriendCell" forIndexPath:indexPath];

    if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FavFriendCell"];
    }

    Friend *friend;
    friend = [[[FriendsStore sharedStore] allFriends] objectAtIndex:indexPath.row];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    friend = [[[FriendsStore sharedStore] searchResults] objectAtIndex:indexPath.row];

    cell.textLabel.text = [friend name];

    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:friend.ava_url]
                   placeholderImage:[UIImage imageNamed:@"no_avatar.png"]];

    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 0;
    cell.imageView.layer.cornerRadius = 32; //cell.imageView.frame.size.height / 2.0;
 
    if ([[[FriendsStore sharedStore] favFriendsIDs] indexOfObject:friend.id_user] != NSNotFound)
    {
        cell.userInteractionEnabled = NO;
        cell.textLabel.enabled = NO;
    }
    else
    {
        cell.userInteractionEnabled = YES;
        cell.textLabel.enabled = YES;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Friend *friend;
    friend = [[[FriendsStore sharedStore] allFriends] objectAtIndex:indexPath.row];
    if (tableView == self.searchDisplayController.searchResultsTableView)
        friend = [[[FriendsStore sharedStore] searchResults] objectAtIndex:indexPath.row];

    if ([[[FriendsStore sharedStore] favFriendsIDs] count] <= self.favID)
    {
        [[[FriendsStore sharedStore] favFriendsIDs] addObject:@""];
    }
    [[FriendsStore sharedStore] favFriendsIDs][self.favID] = friend.id_user;
    [[FriendsStore sharedStore] saveFavFriends];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
