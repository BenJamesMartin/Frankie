//
//  FrankieRegisterViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/23/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Parse/Parse.h>

#import "FrankieRegisterViewController.h"
#import "FrankieMasterContractViewController.h"
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerTapped:(id)sender {

    PFUser *user = [PFUser user];
    user.username = self.email.text;
    user.email = self.email.text;
    user.password = self.password.text;
    
    NSString *alertMessage = [NSString new];
    BOOL showAlertView = NO;
    
    if (self.email.text.length == 0) {
        alertMessage = @"Please enter an email";
        showAlertView = YES;
    }
    else if (self.password.text.length == 0) {
        alertMessage = @"Please enter a password";
        showAlertView = YES;
    }
    else if (![self.password.text isEqualToString:self.verifyPassword.text]) {
        alertMessage = @"Passwords do not match";
        showAlertView = YES;
    }
    if (showAlertView) {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:alertMessage];
        
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alert) {
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleFade;
        
        [alertView show];
        return;
    }
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Account Created!" andMessage:@"Create a new contract by tapping the compose icon in the top right corner."];
            
            [alertView addButtonWithTitle:@"OK"
                                     type:SIAlertViewButtonTypeDestructive
                                  handler:^(SIAlertView *alert) {
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleFade;    
            [alertView show];
  
            FrankieMasterContractViewController * masterVC = [[FrankieMasterContractViewController alloc] init];
            [self.navigationController pushViewController:masterVC animated:YES];
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

#pragma mark - valid email checker

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - dismiss text field

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
