//
//  FrankieClientInformationTableViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 6/7/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

// This class soley exists to create a static table view and create references to the text fields within.

#import <UIKit/UIKit.h>

@interface FrankieClientInformationTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *phoneField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;

@end
