//
//  ViewController.h
//  passingDataTutorial
//
//  Created by Benjamin Martin on 1/9/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController2.h"

@interface ViewController : UIViewController <UITextFieldDelegate, ViewController2Delegate>

@property (weak, nonatomic) IBOutlet UITextField *firstTextField;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (strong, nonatomic) NSString *stringFromVC2;

- (IBAction)passTextToVC2Button:(id)sender;

@end
