//
//  ViewController.m
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
    self.navigationController.navigationBarHidden = YES;
    self.loginButton.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    
    // If the user has already logged in, bring him/her to their list of contracts.
    if ([PFUser currentUser]) {
        self.email.text = [PFUser currentUser].email;
        self.password.text = [PFUser currentUser].password;
//        [self showMasterContractViewController];
    }
}

- (void)showMasterContractViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FrankieMasterContractViewController *masterVC = [storyboard instantiateViewControllerWithIdentifier:@"Master"];
    [self.navigationController pushViewController:masterVC animated:YES];
}

-(void)keyboardShow
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.keyboardScrollView setContentOffset:CGPointMake(0, 130)];
    }];
}

- (void)keyboardDismiss
{
    [UIView animateWithDuration:0.50 animations:^{
        [self.keyboardScrollView setContentOffset:CGPointMake(self.keyboardScrollView.contentOffset.x, -self.keyboardScrollView.contentInset.top)];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField delegate methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField) {
        [textField resignFirstResponder];
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
