//
//  FrankieResetPasswordViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 5/21/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Parse/Parse.h>
#import <UITextField+Shake/UITextField+Shake.h>

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
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = @"Reset Password";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self setSubviewProperties];
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


#pragma mark - valid email checker

- (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (IBAction)resetPassword:(id)sender {
    [self validateTextField:self.email];
    if (![self NSStringIsValidEmail:self.email.text]) {
        [self invalidateTextField:self.email];
        return;
    }
    
    [PFUser requestPasswordResetForEmailInBackground:self.email.text block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self showAlert:nil withMessage:@"Please check your email to reset your password."];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else {
            
        }
    }];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.borderColor = [UIColor clearColor].CGColor;
    FUITextField *tf = (FUITextField *)textField;
    [self validateTextField:tf];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    FUITextField *tf = (FUITextField *)textField;
    [self validateTextField:tf];
    return YES;
}


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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
