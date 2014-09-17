//
//  FavFriendCell.h
//  VKhide
//
//  Created by Mikhail Lukyanov on 16.09.14.
//  Copyright (c) 2014 Михаил Лукьянов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavFriendCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avaImg;
@property (nonatomic, weak) IBOutlet UIImageView *mobileImg;

@property (nonatomic, weak) IBOutlet UILabel *titelLabel;

@end
