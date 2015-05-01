//
//  FrankieSettingsViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/4/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "Contractor.h"

@interface FrankieSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (strong, nonatomic) Contractor *contractor;

@property (strong, nonatomic) IBOutlet UIButton *profileImage;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImagePickerController *mediaPicker;

@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *phoneField;
@property (strong, nonatomic) UITextField *emailField;

@end
