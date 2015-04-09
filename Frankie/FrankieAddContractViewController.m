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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Remove the current selection in our table view
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
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
    
    [self addPadding];
}

- (void) viewWillDisappear:(BOOL)animated
{
    // This was an attempt to get rid of weird error occurring on masterVC
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)addPadding {
    for (id x in [self.keyboardScrollView subviews]) {
        if ([x isKindOfClass:[UITextView class]]) {
            ((UITextView*)x).textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
        }
    }
}

// Adds gesture recognizer to image upload button so can be tapped to dismiss keyboard
- (void)keyboardShown {
    // A single gesture recognizer can only be added to one view, so we need a gesture recognizer for each view.
    for (UIView *view in @[self.keyboardScrollView, self.uploadButton]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismissTap)];
        [view addGestureRecognizer:tap];
    }
}

// When the keyboard dismisses, remove the tap gesture recognizer on the scrollView image upload button
- (void)keyboardDismiss {
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
    NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Job class]) inManagedObjectContext:context];
    
    [entity setValue:self.projectTitle.text forKey:@"title"];
    [entity setValue:self.firstStep.text  forKey:@"nextStep"];
    float price = [[self.price.text stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]] floatValue];
    [entity setValue:[NSNumber numberWithFloat:price] forKey:@"price"];
    [entity setValue:self.notes.text forKey:@"notes"];
    [entity setValue:[NSNumber numberWithBool:NO] forKeyPath:@"completed"];
    [entity setValue:[[[(NSManagedObject*)entity objectID] URIRepresentation] absoluteString] forKey:@"objectId"];
    
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
//    
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

    if (imageData != nil) {
        project[@"photo"] = [PFFile fileWithData:imageData];
    }
    
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [entity setValue:[project objectId] forKeyPath:@"parseId"];
            if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
            }
        }
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)choosePhoto:(id)sender {
    self.mediaPicker = [UIImagePickerController new];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet.title isEqualToString:@"Due Date"]) {
        if (buttonIndex == 0) {
            self.projectDate.textColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:160/255.f alpha:1.0];
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

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (self.mediaPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.uploadButton setImage:image forState:UIControlStateNormal];
    }
    else {
        NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
            self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.uploadButton setImage:copyOfOriginalImage forState:UIControlStateNormal];
         }
        failureBlock:^(NSError *error) {
             // error handling
         }];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITextField delegate

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
        [self showDatePicker];
        return NO;
    }
    else
        return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 1 && textField.text.length > 0) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *replacedText = [textField.text stringByReplacingOccurrencesOfString:formatter.internationalCurrencySymbol withString:@""];
        float fval = [formatter numberFromString:replacedText].floatValue;
        textField.text = [NSString stringWithFormat:@"%.0f", fval];
    }
    
    if (textField == self.price) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.keyboardScrollView setContentOffset:CGPointMake(0, 25)];
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *currency = [f numberFromString:textField.text];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        numberFormatter.maximumFractionDigits = 0;
        NSString *currencyString = [numberFormatter stringFromNumber:currency];
        textField.text = currencyString;
    }
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // If the textField is the price textField, don't let the length of the price textField exceed six numbers
    if (textField.tag == 1) {
        if (range.length + range.location > textField.text.length) {
            return NO;
        }
        
        NSUInteger newLength = textField.text.length + string.length - range.length;
        return (newLength > 7) ? NO : YES;
    }
    return YES;
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
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Due Date"
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


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%lu", indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

// Manually perform navigation controller push to keep reference to each VC
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Steps
    if (indexPath.row == 2) {
        if (self.svc == nil) {
            self.svc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieStepsViewController"];
        }
        [self.svc.view endEditing:YES];
        [self.navigationController pushViewController:self.svc animated:YES];
    }
    // Client information
    else if (indexPath.row == 3) {
        if (self.civc == nil) {
            self.civc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieClientInformationViewController"];
        }
        [self.navigationController pushViewController:self.civc animated:YES];
    }
    // Location (map view)
    else if (indexPath.row == 4) {
        if (self.lvc == nil) {
            self.lvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieLocationViewController"];
        }
        [self.navigationController pushViewController:self.lvc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44; // Default height
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1.0];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1.0];
    return view;
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    return @" ";
//}



@end
