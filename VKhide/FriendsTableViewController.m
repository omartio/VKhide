//
//  FriendsTableViewController.m
//  VKhide
//
//  Created by Михаил Лукьянов on 05.07.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "FriendsStore.h"
#import "Friend.h"
#import "NSDate+Utilities.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SWTableViewCell.h>
#import <NSMutableArray+SWUtilityButtons.h>

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

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
    
    //[self.tableView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VKhideBG.png"]]];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Потяните чтобы обновить"];
    [refresh addTarget:self
                action:@selector(refreshView:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [[FriendsStore sharedStore] updateFriendsListForTableView:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Обновление..."];
    
    [[FriendsStore sharedStore] updateFriendsListForTableView:self];
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
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FriendCell"];
    }
    
    
    Friend *friend;
    friend = [[[FriendsStore sharedStore] allFriends] objectAtIndex:indexPath.row];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
        friend = [[[FriendsStore sharedStore] searchResults] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [friend name];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:friend.ava_url]
                      placeholderImage:[UIImage imageNamed:@"no_avatar.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       image = [self image:image makeRoundCornersWithRadius:image.size.height];
                       if (friend.mobile)
                           image = [self drawImage:image withBadge:[UIImage imageNamed:@"mobile_b.png"]];
                       cell.imageView.image = image;
                             }
     ];

/*
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 0;
    cell.imageView.layer.cornerRadius = 32; //cell.imageView.frame.size.height / 2.0;
 */
 
    //Online
    BOOL online = friend.online;
    if (online)
    {
        cell.detailTextLabel.text = @"В сети";
    }
    else
    {
        NSString *ls = [NSDate lastseenTimestapm:friend.last_seen directTime:NO];
        NSString *sex = [[friend sex] intValue] == 1 ? @"а" : @"";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Был%@ в сети %@", sex, ls];
    }
    
    cell.showsReorderControl = YES;
    
    //NSString *mob = [friend mobile] ? @" (моб.)" : @"";
    //cell.detailTextLabel.text = [cell.detailTextLabel.text stringByAppendingString:mob];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row < [[[FriendsStore sharedStore] additionalUsers] count]);
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[FriendsStore sharedStore]  deleteAdditionalUserWithIndexInArray:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row < [[[FriendsStore sharedStore] additionalUsers] count]);
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
}

-(UIImage *)drawImage:(UIImage*)profileImage withBadge:(UIImage *)badge
{
    UIGraphicsBeginImageContextWithOptions(profileImage.size, NO, 0.0f);
    [profileImage drawInRect:CGRectMake(0, 0, profileImage.size.width, profileImage.size.height)];
    [badge drawInRect:CGRectMake(profileImage.size.width - profileImage.size.width/6.0, profileImage.size.height - profileImage.size.height/6.0, profileImage.size.width/6.0, profileImage.size.height/6.0)];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

-(UIImage*)image:(UIImage *)image makeRoundCornersWithRadius:(const CGFloat)RADIUS {
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    
    const CGRect RECT = CGRectMake(0, 0, image.size.width, image.size.height);
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:RECT cornerRadius:RADIUS] addClip];
    // Draw your image
    [image drawInRect:RECT];
    
    // Get the image, here setting the UIImageView image
    //imageView.image
    UIImage* imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imageNew;
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
