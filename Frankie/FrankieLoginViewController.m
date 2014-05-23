//
//  FrankieLoginViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 1/6/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Parse/Parse.h>

#import "FrankieLoginViewController.h"
#import "FrankieMasterContractViewController.h"
#import "SIAlertView.h"

@interface FrankieLoginViewController ()

@end

@implementation FrankieLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    self.loginButton.userInteractionEnabled = YES;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
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
    if ([PFUser currentUser]) {
        [self showMasterContractViewController];
    }
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(80/255.f) green:(165/255.f) blue:(240/255.f) alpha:1.0];
}

- (void)showMasterContractViewController {
    
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
    self.loginButton.userInteractionEnabled = NO;

    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:self.email.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        PFUser *user = [users firstObject];
        
        [PFUser logInWithUsernameInBackground:user.username password:self.password.text block:^(PFUser *user, NSError *error) {
            // Login succeeded
            if (user) {
                // Move to new view controller
                [self showMasterContractViewController];
            }
            // Login failed
            else {
                self.loginButton.userInteractionEnabled = YES;
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Login failed."];
                
                [alertView addButtonWithTitle:@"OK"
                                         type:SIAlertViewButtonTypeDestructive
                                      handler:^(SIAlertView *alert) {
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleFade;
                
                [alertView show];
            }
        }];
    }];
}

@end
