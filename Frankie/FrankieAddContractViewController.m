//
//  FrankieAddContractViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 1/20/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Parse/Parse.h>

#import "FrankieAddContractViewController.h"
#import "FrankieAppDelegate.h"
#import "Job.h"

@interface FrankieAddContractViewController ()

@end

@implementation FrankieAddContractViewController



// This delegate method called when back button is pressed
// navigation controller's delegate is set in viewDidAppear (versus viewDidLoad) to avoid alert appearing when view first loads
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Exit", @"") message:NSLocalizedString(@"Are you sure you want to leave? New project will be discarded", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Accept", @""), nil];
//    [alertView show];
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom init
    }
    return self;
}

// This is to ask user if he wants to discard changes made on that VC
- (void)backButtonPressed {
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"New Project";
    self.projectDate.text = @"due date";
    [self.uploadButton setImage:[UIImage imageNamed:@"image-upload-icon.png"] forState:UIControlStateNormal];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardDismiss)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(keyboardShown)
                   name:UIKeyboardWillShowNotification
                 object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    // This was an attempt to get rid of weird error occurring on masterVC
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    // Added because app was crashing after making a new contract and returning to tableView
}

// Adds gesture recognizer to image upload button so can be tapped to dismiss keyboard
- (void)keyboardShown {
    // A single gesture recognizer can only be added to one view, so we need to make multiple gesture recognizers.
    for (UIView *view in @[self.keyboardScrollView, self.uploadButton]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismissTap)];
        [view addGestureRecognizer:tap];
    }
}

// When the keyboard dismisses, remove the tap gesture recognizer on the scrollView image upload button
- (void)keyboardDismiss
{
    for (UIView *view in @[self.keyboardScrollView, self.uploadButton]) {
        for (UIGestureRecognizer *gr in [view gestureRecognizers]) {
            if ([gr class] == [UITapGestureRecognizer class]) {
                [view removeGestureRecognizer:gr];
            }
        }
    }
}

-(void) keyboardDismissTap {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - createNewContract

- (IBAction)createNewContract:(id)sender {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Job class]) inManagedObjectContext:context];
    
    [entity setValue:self.projectTitle.text forKey:@"title"];
    [entity setValue:self.firstStep.text  forKey:@"nextStep"];
    float price = [[self.price.text stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
    [entity setValue:[NSNumber numberWithFloat:price] forKey:@"price"];
    [entity setValue:self.notes.text forKey:@"notes"];
    [entity setValue:[NSNumber numberWithBool:NO] forKeyPath:@"completed"];
    [entity setValue:[[[(NSManagedObject*)entity objectID] URIRepresentation] absoluteString]
              forKey:@"objectId"];
    
    NSData *imageData;
    if (!([self.uploadButton imageForState:UIControlStateNormal] == [UIImage imageNamed:@"image-upload-icon"])) {
        UIImage *image = [self.uploadButton imageForState:UIControlStateNormal];
        imageData = UIImageJPEGRepresentation(image, 0.9f);
    }
    else {
        imageData = nil;
    }
    if (imageData != nil) {
        [entity setValue:imageData forKey:@"picture"];
    }
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *projectDate = [dateformatter dateFromString:self.projectDate.text];
    [entity setValue:projectDate forKey:@"dueDate"];
    
    PFObject *project = [PFObject objectWithClassName:@"Project"];
    project[@"user"] = [PFUser currentUser];
    project[@"title"] = self.projectTitle.text;
    
    project[@"start"] = [NSDate date];
    if (![self.projectDate.text isEqualToString:@"due date"]) {
        project[@"end"] = [dateformatter dateFromString:self.projectDate.text];
    }
    
    project[@"completed"] = [NSNumber numberWithBool:NO];
    project[@"price"] = [NSNumber numberWithInt:[self.price.text integerValue]];
    if (![self.notes.text isEqualToString:@"additional notes"]) {
        project[@"notes"] = self.notes.text;
    }
    project.ACL = [PFACL ACLWithUser:[PFUser currentUser]];

    // Make sure this is imageForState or backgroundImageForState according to how it's set
    // Grabbing default image here (not good)
    // Check if it's named image-upload-icon
    
    // If it's that image name, set to nil?

    
    if (imageData != nil) {
        project[@"photo"] = [PFFile fileWithData:imageData];
    }
    
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [entity setValue:[project objectId] forKeyPath:@"parseId"];
            if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

- (IBAction)choosePhoto:(id)sender {
    
    // Add camera capture mode here
    // instead of presenting an image picker, present something that allows you to choose between picking and capturing?
    
    self.mediaPicker = [[UIImagePickerController alloc] init];
    [self.mediaPicker setDelegate:self];
    self.mediaPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];

        [actionSheet showInView:self.view];
    } else {
        self.mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.mediaPicker animated:YES completion:NULL];
    }
}

#pragma mark - UIActionSheetDelegate methods

// Action sheet titles are "Date Picker" and nil

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet.title isEqualToString:@"Date Picker"]) {
        if (buttonIndex == 0) {
            NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"MM/dd/yyyy"];
            [self.projectDate setText:[dateformatter stringFromDate:[self.pickerView date]]];
        }
        return;
    }
    if (buttonIndex == 0) {
        self.mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.mediaPicker animated:YES completion:NULL];
    }
    else if (buttonIndex == 1) {
        self.mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.mediaPicker animated:YES completion:NULL];
    }
}


# pragma mark - UIImagePickerController delegate methods

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (self.mediaPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//        [self.uploadButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.uploadButton setImage:image forState:UIControlStateNormal];
        self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
//                    image.contentMode = UIViewContentModeScaleAspectFill;
    }
    else {
    
        // In here we're setting image from picker
        // We want to grab the fileName with asset.defaultRepresentation.fileName
        // Then we want to add this to Core Data (and probably Parse as well)
        // Can the filename change? Is this secure?
        
        NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
            [self.uploadButton setImage:copyOfOriginalImage forState:UIControlStateNormal];
//            [self.uploadButton setBackgroundImage:copyOfOriginalImage forState:UIControlStateNormal];
            self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
//            UIViewContentModeScaleAspectFill;
//            UIViewContentModeCenter
         }
        failureBlock:^(NSError *error) {
             // error handling
         }];
        
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField) {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.projectDate) {
        textField.textColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:160/255.f alpha:1.0];
        [self showDatePicker];
        return NO;
    }
    else
        return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.price) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.keyboardScrollView setContentOffset:CGPointMake(0, 25)];
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.price) {
        [UIView animateWithDuration:0.50 animations:^{
            [self.keyboardScrollView setContentOffset:CGPointMake(self.keyboardScrollView.contentOffset.x, -self.keyboardScrollView.contentInset.top)];
        }];
        
        if ([textField.text isEqualToString:@""]) {
            float price = textField.text.floatValue;
            textField.text = [NSString stringWithFormat:@"$%.02f", price];
        }
        else {
            float price = [[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
            textField.text = [NSString stringWithFormat:@"$%.02f", price];
        }
    }
}

#pragma mark - UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.keyboardScrollView setContentOffset:CGPointMake(0, 120)];
    }];
    
    if ([textView.text isEqualToString:@"additional notes"]) {
        textView.text = @"";
        textView.textAlignment = NSTextAlignmentLeft;
        textView.textColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:160/255.f alpha:1.0];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    [UIView animateWithDuration:0.50 animations:^{
        [self.keyboardScrollView setContentOffset:CGPointMake(self.keyboardScrollView.contentOffset.x, -self.keyboardScrollView.contentInset.top)];
    }];
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"additional notes";
        textView.textAlignment = NSTextAlignmentCenter;
        textView.textColor = [UIColor colorWithRed:185/255.f green:185/255.f blue:185/255.f alpha:1.0];
    }
    [textView resignFirstResponder];
}

- (void)showDatePicker
{
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Date Picker"
                                                      delegate:self
                                             cancelButtonTitle:@""
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"Set", nil];
    
    // Add the picker
    if (self.pickerView == nil) {
        self.pickerView = [[UIDatePicker alloc] init];
    }
    
    self.pickerView.datePickerMode = UIDatePickerModeDate;
    [menu addSubview:self.pickerView];
    [menu showInView:self.view];
    [menu setBounds:CGRectMake(0,0,320, 500)];
    
    CGRect pickerRect = self.pickerView.bounds;
    pickerRect.origin.y = -100;
    self.pickerView.bounds = pickerRect;
}



@end
