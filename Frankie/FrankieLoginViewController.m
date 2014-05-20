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
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.frankie.font = [UIFont fontWithName:@"Proxima Nova Soft" size:34.f];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.keyboardScrollView.alwaysBounceVertical = YES;
    self.keyboardScrollView.alwaysBounceHorizontal = NO;
    
    self.email.delegate = self;
    self.password.delegate = self;
    self.keyboardScrollView.delegate = self;
    
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
//        self.email.text = [PFUser currentUser].email;
        
        [self showMasterContractViewController];
    }
}

- (void)showMasterContractViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FrankieMasterContractViewController *masterVC = [storyboard instantiateViewControllerWithIdentifier:@"Master"];
    [self.navigationController pushViewController:masterVC animated:YES];
}

#pragma mark - UIScrollView delegate methods

// Just setting the x-position to 0?
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender.contentOffset.x != 0) {
        CGPoint offset = sender.contentOffset;
        offset.x = 0;
        sender.contentOffset = offset;
    }
}

-(void)keyboardShow
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.keyboardScrollView setContentOffset:CGPointMake(0, 130)];
    }];
}

- (void)keyboardDismiss
{
//    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
    [self.keyboardScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // Obtain username for email
    // Fetch user object for given email
    // Grab username for that user object
    
    // Simple findObjects call produces "A long-running Parse operation is being executed on the main thread" warning.
    // A background call is needed to avoid this. To avoid two VCs being pushed at once and getting "Unbalanced calls to begin/end appearance transitions" warning (which is followed by a crash on next VC transition), avoid setting query.cachePolicy = kPFCacheThenNetwork. Cacheing does something weird that makes multiple instances of the same VC be pushed.

    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:self.email.text];

    // Log in user with the given password.
    // A failed login will give a generic "missing user password" error.
    // Need to have button in alertView that takes user to be able to reset password
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        PFUser *user = [users firstObject];
        
        [PFUser logInWithUsernameInBackground:user.username password:self.password.text
                                        block:^(PFUser *user, NSError *error) {
                                            // Login succeeded
                                            if (user) {
                                                // Move to new view controller
                                                [self showMasterContractViewController];
                                            }
                                            // Login failed
                                            else {
                                                // Add option to retrieve password
                                                // Add button to alertView that will bring up new view
                                                // This new view has form for email to reset new password
                                                // Parse should take care of doing this for you
                                                
                                                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:@"Login failed."];
                                                
                                                [alertView addButtonWithTitle:@"OK"
                                                                         type:SIAlertViewButtonTypeDestructive
                                                                      handler:^(SIAlertView *alert) {
                                                                      }];
                                                alertView.transitionStyle = SIAlertViewTransitionStyleFade;
                                                
                                                [alertView show];
                                                
                                                // https://parse.com/docs/ios_guide#users-resetting/iOS
//                                                NSLog(@"login error %@", [error userInfo][@"error"]);
//                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login failed." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                                                [alert show];
                                            }
                                        }];
    }];
}

@end
