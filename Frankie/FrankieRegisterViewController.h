//
//  FrankieRegisterViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/23/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>

#import "FrankieMasterContractViewController.h"

@interface FrankieRegisterViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet FUITextField *email;
@property (strong, nonatomic) IBOutlet FUITextField *password;
@property (strong, nonatomic) IBOutlet FUITextField *verifyPassword;
@property (strong, nonatomic) IBOutlet UIImageView *check;
@property (strong, nonatomic) IBOutlet UIImageView *x;
@property (strong, nonatomic) NSString *currentEmail;

- (IBAction)registerTapped:(id)sender;

@end
