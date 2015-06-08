//
//  FrankieAddContractViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 1/20/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

#import "FrankieStepsViewController.h"
#import "FrankieStepsDetailViewController.h"
#import "FrankieClientInformationViewController.h"
#import "FrankieLocationViewController.h"
#import "FrankieNotesViewController.h"
#import "Project.h"

@interface FrankieAddEditContractViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITableViewCell *stepsCell;

@property (strong, nonatomic) UIDatePicker *pickerView;
@property (strong, nonatomic) UIGestureRecognizer *touch;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) UITextField *projectTitle;
@property (strong, nonatomic) UITextField *price;
@property (strong, nonatomic) UIImagePickerController *mediaPicker;

// Determines whether to show warning before cancelling project upload
@property (assign, nonatomic) BOOL projectHasBeenEdited;

@property (strong, nonatomic) FrankieStepsViewController *svc;
@property (strong, nonatomic) FrankieClientInformationViewController *civc;
@property (strong, nonatomic) FrankieLocationViewController *lvc;
@property (strong, nonatomic) FrankieNotesViewController *nvc;

@property (strong, nonatomic) NSDictionary *clientInformation;
@property (strong, nonatomic) CLPlacemark *locationPlacemark;
@property (assign, nonatomic) int stepCount;
@property (strong, nonatomic) NSMutableArray *steps;
@property (strong, nonatomic) NSString *notes;

// When loading contract from master VC, set job model
// When loading contract from step VC (navigating backwards), do not set job model
@property (assign, nonatomic) BOOL shouldSetJobInViewDidAppear;

@property (strong, nonatomic) Project *project;

// Used to determine if step cell should navigate directly to add/edit step VC to create first step instead of master step VC showing all steps (of which there'd be none)
@property (assign, nonatomic) BOOL isCreatingFirstStep;

- (IBAction)createOrEditProject:(id)sender;

@end
