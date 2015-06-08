//
//  FrankieClientInformationViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/5/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrankieClientInformationTableViewController.h"

@interface FrankieClientInformationViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *infoField;
@property (strong, nonatomic) NSMutableDictionary *clientInformation;

@property (strong, nonatomic) FrankieClientInformationTableViewController *childTableView;


@end
