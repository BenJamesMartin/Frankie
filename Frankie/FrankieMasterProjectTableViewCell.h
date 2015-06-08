//
//  FrankieMasterProjectTableViewCell.h
//  Frankie
//
//  Created by Benjamin Martin on 4/13/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrankieMasterProjectTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *picture;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *nextStepName;
@property (strong, nonatomic) IBOutlet UILabel *nextStepDueDate;
@property (strong, nonatomic) IBOutlet UIImageView *lateStepIcon;
@property (strong, nonatomic) IBOutlet UILabel *projectCompleteLabel;

@end
