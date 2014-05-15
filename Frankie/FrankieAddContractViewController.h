//
//  FrankieAddContractViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 1/20/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface FrankieAddContractViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *keyboardScrollView;
@property (strong, nonatomic) UIDatePicker *pickerView;
@property (strong, nonatomic) IBOutlet UITextField *projectDate;
@property (strong, nonatomic) UIGestureRecognizer *touch;
@property (strong, nonatomic) UITextField *activeField;
@property (strong, nonatomic) IBOutlet UITextField *projectTitle;
@property (strong, nonatomic) IBOutlet UITextField *firstStep;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UITextView *notes;
@property (strong, nonatomic) IBOutlet UITextField *price;
@property (strong, nonatomic) UIImagePickerController *mediaPicker;

- (IBAction)createNewContract:(id)sender;

@end
