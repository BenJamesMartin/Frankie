//
//  FrankieLoginViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 1/6/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Parse/Parse.h>
#import <UITextField+Shake/UITextField+Shake.h>

#import "FrankieLoginViewController.h"
#import "FrankieMasterContractViewController.h"
#import "SIAlertView.h"
#import "RTNActivityView.h"

@interface FrankieLoginViewController ()

@end

@implementation FrankieLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    self.loginButton.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.keyboardScrollView.alwaysBounceVertical = YES;
    self.keyboardScrollView.alwaysBounceHorizontal = NO;
    
    // defaultCenter for hiding keyboard
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardDismiss)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(keyboardShow)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    
    // Take the user to his contracts if he's already logged in
//    if ([PFUser currentUser]) {
//        [self navigateToMasterContractViewController];
//    }
    
    [self setSubviewProperties];
}

- (void)setSubviewProperties {
    UIColor *textFieldBorderColor = [UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1.0];
    
    self.email.backgroundColor = [UIColor clearColor];
    self.email.textFieldColor = [UIColor whiteColor];
    self.email.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.email.borderColor = textFieldBorderColor;
    self.email.borderWidth = 2.0f;
    self.email.cornerRadius = 3.0f;
    self.email.placeholder = @"Email Address";
    self.email.textColor = [UIColor darkGrayColor];
    
    self.password.delegate = self;
    self.password.secureTextEntry = YES;
    self.password.backgroundColor = [UIColor clearColor];
    self.password.textFieldColor = [UIColor whiteColor];
    self.password.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.password.borderColor = textFieldBorderColor;
    self.password.borderWidth = 2.0f;
    self.password.cornerRadius = 3.0f;
    self.password.placeholder = @"Password";
    self.password.textColor = [UIColor darkGrayColor];
}

- (void)navigateToMasterContractViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FrankieMasterContractViewController *masterVC = [storyboard instantiateViewControllerWithIdentifier:@"Master"];
    [self.navigationController pushViewController:masterVC animated:YES];
}

-(void)keyboardShow
{
    for (UIView *view in @[self.keyboardScrollView]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismissTap)];
        [view addGestureRecognizer:tap];
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self.keyboardScrollView setContentOffset:CGPointMake(0, 130)];
    }];
}

- (void)keyboardDismiss {
    for (UIView *view in @[self.keyboardScrollView]) {
        for (UIGestureRecognizer *gr in [view gestureRecognizers]) {
            if ([gr class] == [UITapGestureRecognizer class]) {
                [view removeGestureRecognizer:gr];
            }
        }
    }
    [UIView animateWithDuration:0.50 animations:^{
        [self.keyboardScrollView setContentOffset:CGPointMake(self.keyboardScrollView.contentOffset.x, -self.keyboardScrollView.contentInset.top)];
    }];
}

-(void) keyboardDismissTap {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField) {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

#pragma mark - Login authentication

- (IBAction)authenticateUser:(id)sender {
    // Check to make sure any text at all is present in email/password fields
    BOOL shouldNotLogin = NO;
    if (self.email.text.length < 1 || ![self NSStringIsValidEmail:self.email.text]) {
        shouldNotLogin = YES;
        [self invalidateTextField:self.email];
    }
    else if (self.password.text.length < 1) {
        shouldNotLogin = YES;
        [self invalidateTextField:self.password];
        [self validateTextField:self.email];
    }
    else {
        [self validateAllTextFields];
    }
    if (shouldNotLogin)
        return;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:self.email.text];
    [RTNActivityView show];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        [RTNActivityView hide];
        BOOL shouldLogin = YES;
        // Email incorrect
        if (users.count == 0) {
            shouldLogin = NO;
            
            [self validateAllTextFields];
            [self invalidateTextField:self.email];
        }
        
        if (shouldLogin) {
            PFUser *user = [users firstObject];
            [RTNActivityView show];
            [PFUser logInWithUsernameInBackground:user.username password:self.password.text block:^(PFUser *user, NSError *error) {
                [RTNActivityView hide];
                // Password incorrect
                if (error) {
                    [self validateAllTextFields];
                    [self invalidateTextField:self.password];
                }
                else {
                    [self navigateToMasterContractViewController];
                }
            }];
        }
    }];
    
//    self.loginButton.userInteractionEnabled = NO;
//
//    PFQuery *query = [PFUser query];
//    [query whereKey:@"email" equalTo:self.email.text];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
//        PFUser *user = [users firstObject];
//        
//        [PFUser logInWithUsernameInBackground:user.username password:self.password.text block:^(PFUser *user, NSError *error) {
//            // Login succeeded
//            if (user) {
//                // Move to new view controller
//                [self showMasterContractViewController];
//            }
//            // Login failed
//            else {
//                self.loginButton.userInteractionEnabled = YES;
//                
//                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Login failed."];
//                
//                [alertView addButtonWithTitle:@"OK"
//                                         type:SIAlertViewButtonTypeDestructive
//                                      handler:^(SIAlertView *alert) {
//                                      }];
//                alertView.transitionStyle = SIAlertViewTransitionStyleFade;
//                
//                [alertView show];
//            }
//        }];
//    }];
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

- (void)validateAllTextFields
{
    self.email.borderColor = [UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1.0];
    self.password.borderColor = [UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1.0];
}

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

@end
