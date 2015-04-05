//
//  FrankieResetPasswordViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 5/21/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>

@interface FrankieResetPasswordViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet FUITextField *email;

@end
