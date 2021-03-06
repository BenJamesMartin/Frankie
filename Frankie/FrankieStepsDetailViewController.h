//
//  FrankieStepsDetailViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/7/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "Step.h"

@interface FrankieStepsDetailViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Step *step;

@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) UIImagePickerController *mediaPicker;
@property (assign, nonatomic) BOOL hasSelectedImage;

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *dueDateField;

@property (assign, nonatomic) BOOL hasChangedBackButton;

@property (assign, nonatomic) BOOL stepHasBeenEdited;
@property (strong, nonatomic) IBOutlet UIButton *createButton;

// This step is the first step to be added. Used to determine how view controller navigations should animate.
@property (assign, nonatomic) BOOL isFirstStep;

@end
