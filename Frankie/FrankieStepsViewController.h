//
//  FrankieStepsViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/6/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrankieStepsViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *steps;
@property (assign, nonatomic) int stepCount;

@property (strong, nonatomic) NSMutableDictionary *cellForDetailView;

@end
