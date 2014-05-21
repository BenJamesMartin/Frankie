//
//  FrankieResetPasswordViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 5/21/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Parse/Parse.h>

#import "FrankieResetPasswordViewController.h"
#import "SIAlertView.h"

@interface FrankieResetPasswordViewController ()

@end

@implementation FrankieResetPasswordViewController

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
    [self.scrollView bounces];
    [self.scrollView alwaysBounceVertical];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)showAlert:(NSString*)title withMessage:(NSString*)message {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleFade;
    
    [alertView show];
}

- (IBAction)resetPassword:(id)sender {
    [PFUser requestPasswordResetForEmailInBackground:self.email.text block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self showAlert:nil withMessage:@"Please check your email to reset your password."];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField) {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
