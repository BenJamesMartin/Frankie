//
//  FrankieRegisterViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/23/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Parse/Parse.h>
#import <UITextField+Shake/UITextField+Shake.h>

#import "RTNActivityView.h"
#import "FrankieRegisterViewController.h"
#import "FrankieMasterContractViewController.h"
#import "FrankieAppDelegate.h"
#import "SIAlertView.h"

@interface FrankieRegisterViewController ()

@end

@implementation FrankieRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Register";
    
    [self setSubviewProperties];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setSubviewProperties
{
    UIColor *textFieldBorderColor = [UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1.0];
    
    self.email.backgroundColor = [UIColor clearColor];
    self.email.textFieldColor = [UIColor whiteColor];
    self.email.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.email.borderColor = textFieldBorderColor;
    self.email.borderWidth = 2.0f;
    self.email.cornerRadius = 3.0f;
    
    self.password.backgroundColor = [UIColor clearColor];
    self.password.textFieldColor = [UIColor whiteColor];
    self.password.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.password.borderColor = textFieldBorderColor;
    self.password.borderWidth = 2.0f;
    self.password.cornerRadius = 3.0f;
    
    self.verifyPassword.backgroundColor = [UIColor clearColor];
    self.verifyPassword.textFieldColor = [UIColor whiteColor];
    self.verifyPassword.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.verifyPassword.borderColor = textFieldBorderColor;
    self.verifyPassword.borderWidth = 2.0f;
    self.verifyPassword.cornerRadius = 3.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerTapped:(id)sender
{
    PFUser *user = [PFUser user];
    user.username = self.email.text;
    user.email = self.email.text;
    user.password = self.password.text;
    
    //    NSString *alertMessage = @"";
    //    BOOL showAlertView = NO;
    
    // No email provided
    if (self.email.text.length == 0 || ![self NSStringIsValidEmail:self.email.text]) {
        [self invalidateTextField:self.email];
        //        alertMessage = @"Please enter an email";
        //        showAlertView = YES;
    }
    // No password provided
    else if (self.password.text.length == 0) {
        [self invalidateTextField:self.password];
        //        alertMessage = @"Please enter a password";
        //        showAlertView = YES;
    }
    // Passwords provided do not match
    else if (![self.password.text isEqualToString:self.verifyPassword.text]) {
        [self invalidateTextField:self.verifyPassword];
        //        alertMessage = @"Passwords do not match";
        //        showAlertView = YES;
    }
    // All fields are filled out and passwords match
    else {
        [RTNActivityView show];
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Account Created!" andMessage:@"Create a new contract by tapping the compose icon in the top right corner."];
                
                [alertView addButtonWithTitle:@"OK"
                                         type:SIAlertViewButtonTypeDestructive
                                      handler:^(SIAlertView *alert) {
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleFade;
                [alertView show];
                
                FrankieAppDelegate *delegate = (FrankieAppDelegate *)[[UIApplication sharedApplication] delegate];
                FrankieMasterContractViewController *masterVC = [[FrankieMasterContractViewController alloc] init];
                delegate.masterVC = masterVC;
                [self.navigationController pushViewController:masterVC animated:YES];
                [RTNActivityView hide];
            }
            else {
                NSString *errorMessage = [[NSString alloc] init];
                switch ([[error userInfo][@"code"] integerValue]) {
                    case 203:
                        if ([self.email.text length] == 0) {
                            errorMessage = @"Please enter an email address.";
                        }
                        else {
                            errorMessage = @"Email address already in use.";
                        }
                        break;
                    case 125:
                        errorMessage = @"Email address is invalid.";
                        break;
                    case 200:
                        errorMessage = @"Please enter an email address.";
                        break;
                    case 201:
                        errorMessage = @"Please enter a password.";
                        break;
                    case 202:
                        errorMessage = @"Email address already in use.";
                        break;
                    default:
                        break;
                }
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:errorMessage];
                
                [alertView addButtonWithTitle:@"OK"
                                         type:SIAlertViewButtonTypeDestructive
                                      handler:^(SIAlertView *alert) {
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleFade;
                
                [alertView show];
            }
        }];

    }

    
//    PFUser *user = [PFUser user];
//    user.username = self.email.text;
//    user.email = self.email.text;
//    user.password = self.password.text;
//    
//    NSString *alertMessage = [NSString new];
//    BOOL showAlertView = NO;
//    
//    if (self.email.text.length == 0) {
//        alertMessage = @"Please enter an email";
//        showAlertView = YES;
//    }
//    else if (self.password.text.length == 0) {
//        alertMessage = @"Please enter a password";
//        showAlertView = YES;
//    }
//    else if (![self.password.text isEqualToString:self.verifyPassword.text]) {
//        alertMessage = @"Passwords do not match";
//        showAlertView = YES;
//    }
//    if (showAlertView) {
//        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:alertMessage];
//        
//        [alertView addButtonWithTitle:@"OK"
//                                 type:SIAlertViewButtonTypeDestructive
//                              handler:^(SIAlertView *alert) {
//                              }];
//        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
//        
//        [alertView show];
//        return;
//    }
//    
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {
//            
//            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Account Created!" andMessage:@"Create a new contract by tapping the compose icon in the top right corner."];
//            
//            [alertView addButtonWithTitle:@"OK"
//                                     type:SIAlertViewButtonTypeDestructive
//                                  handler:^(SIAlertView *alert) {
//                                  }];
//            alertView.transitionStyle = SIAlertViewTransitionStyleFade;    
//            [alertView show];
//  
//            FrankieMasterContractViewController * masterVC = [[FrankieMasterContractViewController alloc] init];
//            [self.navigationController pushViewController:masterVC animated:YES];
//        }
//        else {
//            NSString *errorMessage = [[NSString alloc] init];
//            switch ([[error userInfo][@"code"] integerValue]) {
//                case 203:
//                    if ([self.email.text length] == 0) {
//                        errorMessage = @"Please enter an email address.";
//                    }
//                    else {
//                        errorMessage = @"Email address already in use.";
//                    }
//                    break;
//                case 125:
//                    errorMessage = @"Email address is invalid.";
//                    break;
//                case 200:
//                    errorMessage = @"Please enter an email address.";
//                    break;
//                case 201:
//                    errorMessage = @"Please enter a password.";
//                    break;
//                case 202:
//                    errorMessage = @"Email address already in use.";
//                    break;
//                default:
//                    break;
//            }
//            
//            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:errorMessage];
//            
//            [alertView addButtonWithTitle:@"OK"
//                                     type:SIAlertViewButtonTypeDestructive
//                                  handler:^(SIAlertView *alert) {
//                                  }];
//            alertView.transitionStyle = SIAlertViewTransitionStyleFade;
//            
//            [alertView show];
//        }
//    }];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor clearColor].CGColor;
    FUITextField *tf = (FUITextField *)textField;
    [self validateTextField:tf];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    FUITextField *tf = (FUITextField *)textField;
//    [self validateTextField:tf];
//    return YES;
//}


#pragma mark - Validate/Invalidate text fields

- (void)validateTextField:(FUITextField *)textField
{
    textField.borderColor = [UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1.0];
}

- (void)invalidateTextField:(FUITextField *)textField
{
    int numberOfShakes = 5;
    CGFloat shakeDelta = 8.0;
    NSTimeInterval shakeDuration = 0.03;
    
    textField.layer.borderWidth = 2.0;
    textField.layer.borderColor = [UIColor alizarinColor].CGColor;
    textField.borderColor = [UIColor alizarinColor];
    [textField shake:numberOfShakes withDelta:shakeDelta andSpeed:shakeDuration];
}


#pragma mark - Valid email checker

- (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - Dismiss text field

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField) {
        [textField resignFirstResponder];
    }
    return NO;
}

// Give feedback that username is already taken
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.email) {
    
        if (string.length == 0) {
            self.currentEmail = [[self.email.text stringByAppendingString:string] substringToIndex:[self.email.text stringByAppendingString:string].length - 1];
        }
        else {
            self.currentEmail = [self.email.text stringByAppendingString:string];
        }
        
        if ([self NSStringIsValidEmail:self.currentEmail]) {
            PFQuery *query = [PFUser query];
            [query whereKey:@"email" equalTo:self.currentEmail];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                if (users.count == 0) {
                    self.check.hidden = NO;
                    self.x.hidden = YES;
                }
                else {
                    self.check.hidden = YES;
                    self.x.hidden = NO;
                }
            }];
        }
        else {
            self.check.hidden = YES;
        }
   }
    return YES;
}

@end
