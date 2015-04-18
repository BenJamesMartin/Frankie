//
//  FrankieProjectDetailStepsTableViewCell.h
//  Frankie
//
//  Created by Benjamin Martin on 4/15/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrankieProjectDetailStepsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *checkmarkImage;
@property (strong, nonatomic) IBOutlet UIImageView *picture;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *dueIn;


@end
