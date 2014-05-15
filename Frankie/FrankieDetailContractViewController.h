//
//  SingleContractViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 1/9/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrankieDetailContractViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate>



@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *editTitleButton;
@property (strong, nonatomic) IBOutlet UIButton *editPriceButton;
@property (strong, nonatomic) IBOutlet UIButton *editNotesButton;

@property (strong, nonatomic) IBOutlet UITextField *titleField;

@property (strong, nonatomic) IBOutlet UITextField *priceField;


@property (strong, nonatomic) IBOutlet UILabel *dueDate;

@property (strong, nonatomic) IBOutlet UITextView *notesField;

@property (strong, nonatomic) IBOutlet UIButton *picture;
@property (strong, nonatomic) UIImagePickerController *mediaPicker;

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSString *blah;
@property (strong, nonatomic) NSDictionary *project;

@property (strong, nonatomic) UIDatePicker *pickerView;

@end
