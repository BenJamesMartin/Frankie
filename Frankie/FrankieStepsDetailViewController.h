//
//  FrankieStepsDetailViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/7/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ProjectStep.h"

@interface FrankieStepsDetailViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UITextField *nameField;
//@property (strong, nonatomic) UITextField *dueDateField;

@property (strong, nonatomic) UIImagePickerController *mediaPicker;
@property (assign, nonatomic) BOOL hasSelectedImage;

@property (strong, nonatomic) ProjectStep *step;

@property (strong, nonatomic) IBOutlet UITextField *dueDateField;


@end
