//
//  FrankieResetPasswordViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 5/21/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrankieResetPasswordViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
