//
//  FrankieDetailContractViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 1/9/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrankieDetailContractViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSDictionary *project;

@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextField *priceField;
@property (strong, nonatomic) IBOutlet UITextField *dueDate;

@property (strong, nonatomic) IBOutlet UIButton *picture;
@property (strong, nonatomic) UIImagePickerController *mediaPicker;

@property (strong, nonatomic) IBOutlet UIButton *projectCompleteButton;
@property (strong, nonatomic) UIGestureRecognizer *touch;

@end
