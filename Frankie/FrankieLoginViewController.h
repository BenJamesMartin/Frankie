//
//  FrankieLoginViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 1/6/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>

@interface FrankieLoginViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *frankie;
@property (strong, nonatomic) IBOutlet FUITextField *email;
@property (strong, nonatomic) IBOutlet FUITextField *password;
@property (strong, nonatomic) IBOutlet UIScrollView *keyboardScrollView;

- (IBAction)authenticateUser:(id)sender;
@property (strong, nonatomic) IBOutlet FUIButton *loginButton;

@end
