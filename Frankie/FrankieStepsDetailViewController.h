//
//  FrankieStepsDetailViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/7/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrankieStepsDetailViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *dueDateField;

@property (strong, nonatomic) UIDatePicker *pickerView;
@property (strong, nonatomic) UIImagePickerController *mediaPicker;



@end
