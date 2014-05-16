//
//  FrankieMasterContractViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 1/8/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class FrankieMasterContractViewController;

@interface FrankieMasterContractViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UIImageView *defaultImage;
@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)loadAddContractViewController;

@end
