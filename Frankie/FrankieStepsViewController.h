//
//  FrankieStepsViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/6/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrankieStepsDetailViewController.h"

@interface FrankieStepsViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *steps;
// Used to determine whether to reload table data and automatically show the detail VC (if no steps have been created yet)
//@property (assign, nonatomic) BOOL isNavigatingFromStepDetail;

@end
