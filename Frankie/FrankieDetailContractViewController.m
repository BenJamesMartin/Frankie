//
//  SingleContractViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 1/9/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <Parse/Parse.h>

#import "FrankieAppDelegate.h"
#import "Job.h"
#import "FrankieDetailContractViewController.h"


@interface FrankieDetailContractViewController ()

@end

@implementation FrankieDetailContractViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if ([[self.project objectForKey:@"title"] isEqualToString:@""]) {
            self.titleField.text = @"[Title Not Set]";
    }
    else {
        self.titleField.text = [self.project objectForKey:@"title"];
    }
    
    if ([[self.project objectForKey:@"price"] floatValue] == 0) {
        self.priceField.text = @"[Price Not Set]";
    }
    else {
        NSNumber *number = (NSNumber*)[self.project objectForKey:@"price"];
        self.priceField.text = [NSString stringWithFormat:@"$%.02f", number.floatValue];
    }
    
    if ([self.project objectForKey:@"dueDate"] == nil || [self.project objectForKey:@"dueDate"] == [NSNull null]) {
        self.dueDate.text  = @"[Due Date Not Set]";
    }
    else {
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"MM/dd/yyyy"];
        self.dueDate.text  = [dateformatter stringFromDate:[self.project objectForKey:@"dueDate"]];
    }
    if ([self.project objectForKey:@"notes"] == nil || [self.project objectForKey:@"notes"] == [NSNull null] || [[self.project objectForKey:@"notes"] isEqualToString:@"additional notes"]) {
        self.notesField.text = @"[No Notes]";
    }
    else {
        self.notesField.text = [self.project objectForKey:@"notes"];
    }
    if (self.project[@"picture"] != nil && self.project[@"picture"] != [NSNull null]) {
        [self.picture setImage:[UIImage imageWithData:self.project[@"picture"]] forState:UIControlStateNormal];
    }
    else {
        [self.picture setImage:[UIImage imageNamed:@"image-upload-icon"] forState:UIControlStateNormal];
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
//    [self performSelector:@selector(updateModel) withObject:nil afterDelay:0];
}

- (void)updateModel {
//    NSData *imageData;
//    if (!([self.picture imageForState:UIControlStateNormal] == [UIImage imageNamed:@"image-upload-icon"])) {
//        UIImage *image = [self.picture imageForState:UIControlStateNormal];
//        imageData = UIImageJPEGRepresentation(image, 0.9f);
//    }
//    else {
//        imageData = nil;
//    }
//    
//    PFQuery *postQuery = [PFQuery queryWithClassName:@"Project"];
//    [postQuery whereKey:@"objectId" equalTo:self.project[@"parseId"]];
//    // Run the query
//    [postQuery getFirstObjectInBackgroundWithBlock:^(PFObject *project, NSError *error) {
//        if (!error) {
//            if (![self.titleField.text isEqualToString:@"[Title Not Set]"] || self.titleField.text != nil) {
//                project[@"title"] = self.titleField.text;
//            }
//            if (![self.priceField.text isEqualToString:@"[Price Not Set]"] || self.priceField.text != nil) {
//                float price = [self.priceField.text stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]].floatValue;
//                project[@"price"] = [NSNumber numberWithFloat:price];
//            }
//            if (![self.dueDate.text isEqualToString:@"[Due Date Not Set]"]) {
//                NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
//                [dateformatter setDateFormat:@"MM/dd/yyyy"];
//                project[@"end"] = [dateformatter dateFromString:self.dueDate.text];
//            }
//            if (![self.notesField.text isEqualToString:@"[No Notes"] || self.notesField.text != nil) {
//                project[@"notes"] = self.notesField.text;
//            }
//            if (imageData != nil) {
//                project[@"photo"] = [PFFile fileWithData:imageData];
//            }
//            
//            [project saveInBackground];
//        }
//    }];
//    
//    NSError *error;
//    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
//    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Job class])];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", self.project[@"objectId"]];
//    [request setPredicate:predicate];
//    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"objectId" ascending:YES];
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
//    [request setSortDescriptors:sortDescriptors];
//    
//    Job *job = [[context executeFetchRequest:request error:&error] objectAtIndex:0];
//    
//    if (![self.titleField.text isEqualToString:@"[Title Not Set"]) {
//        job.title = self.titleField.text;
//    }
//    if (![self.priceField.text isEqualToString:@"[Price Not Set"]) {
//        float price = [self.priceField.text stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]].floatValue;
//        job.price = [NSNumber numberWithFloat:price];
//    }
//    if (![self.priceField.text isEqualToString:@"[Date Not Set"]) {
//        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
//        [dateformatter setDateFormat:@"MM/dd/yyyy"];
//        job.dueDate = [dateformatter dateFromString:self.dueDate.text];
//    }
//    if (![self.notesField.text isEqualToString:@"[No Notes"]) {
//        job.notes = self.notesField.text;
//    }
//    
//    if (imageData != nil) {
//        job.picture = imageData;
//    }
//    
//    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

#pragma mark - Edit buttons for title, price, and due date

- (IBAction)editTitle:(id)sender {
    if (self.titleField.userInteractionEnabled == NO) {
        [self.titleField setUserInteractionEnabled:YES];
        [self.titleField becomeFirstResponder];
        [sender setTitle:@"Done" forState:UIControlStateNormal];
    }
    else {
        [self.titleField resignFirstResponder];
    }
}

- (IBAction)editPrice:(id)sender {
    if (self.priceField.userInteractionEnabled == NO) {
        [self.priceField setUserInteractionEnabled:YES];
        [self.priceField becomeFirstResponder];
        [sender setTitle:@"Done" forState:UIControlStateNormal];
    }
    else {
        [self.priceField resignFirstResponder];
    }
}


// Need to make call to update Core Data object from here
// What this is doing:
//  - Shows label by default
//  - textField is hidden in storyboard
//  - Make similar fields for
//  - Add done buttons on each text field
- (IBAction)editDueDate:(id)sender {
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Date Picker"
                                                      delegate:self
                                             cancelButtonTitle:@"Set"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil];
    
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

- (IBAction)editNotes:(id)sender {
    if (self.notesField.userInteractionEnabled == NO) {
        [self.notesField setUserInteractionEnabled:YES];
        [self.notesField becomeFirstResponder];
        [sender setTitle:@"Done" forState:UIControlStateNormal];
    }
    else {
        [self.notesField resignFirstResponder];
    }

}


- (IBAction)editModelObject:(id)sender {
    
    // Update data for given project in both Parse and Core Data
    // Fetch object, change it, and resave context
    
    // How are we grabbing the data from Parse?
    // Need to add Parse ObjectId field to database?
    
    NSData *imageData;
    if (!([self.picture imageForState:UIControlStateNormal] == [UIImage imageNamed:@"image-upload-icon"])) {
        UIImage *image = [self.picture imageForState:UIControlStateNormal];
        imageData = UIImageJPEGRepresentation(image, 0.9f);
    }
    else {
        imageData = nil;
    }
    
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Project"];
    [postQuery whereKey:@"objectId" equalTo:self.project[@"parseId"]];
    // Run the query
    [postQuery getFirstObjectInBackgroundWithBlock:^(PFObject *project, NSError *error) {
        if (!error) {
            if (![self.titleField.text isEqualToString:@"[Title Not Set]"] || self.titleField.text != nil) {
                project[@"title"] = self.titleField.text;
            }
            if (![self.priceField.text isEqualToString:@"[Price Not Set]"] || self.priceField.text != nil) {
                float price = [self.priceField.text stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]].floatValue;
                project[@"price"] = [NSNumber numberWithFloat:price];
            }
            if (![self.dueDate.text isEqualToString:@"[Due Date Not Set]"]) {
                NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
                [dateformatter setDateFormat:@"MM/dd/yyyy"];
                project[@"end"] = [dateformatter dateFromString:self.dueDate.text];
            }
            if (![self.notesField.text isEqualToString:@"[No Notes"] || self.notesField.text != nil) {
                project[@"notes"] = self.notesField.text;
            }
            if (imageData != nil) {
                project[@"photo"] = [PFFile fileWithData:imageData];
            }

            [project saveInBackground];
        }
    }];
    
    NSError *error;
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Job class])];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", self.project[@"objectId"]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"objectId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];

    Job *job = [[context executeFetchRequest:request error:&error] objectAtIndex:0];
    
    if (![self.titleField.text isEqualToString:@"[Title Not Set"]) {
        job.title = self.titleField.text;
    }
    if (![self.priceField.text isEqualToString:@"[Price Not Set"]) {
        float price = [self.priceField.text stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]].floatValue;
        job.price = [NSNumber numberWithFloat:price];
    }
    if (![self.priceField.text isEqualToString:@"[Date Not Set"]) {
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"MM/dd/yyyy"];
        job.dueDate = [dateformatter dateFromString:self.dueDate.text];
    }
    if (![self.notesField.text isEqualToString:@"[No Notes"]) {
        job.notes = self.notesField.text;
    }

    if (imageData != nil) {
        job.picture = imageData;
    }
    
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    NSLog(@"button clicked");
    if ([actionSheet.title isEqualToString:@"Delete"]) {
        if (buttonIndex == 1)
        {
            PFQuery *postQuery = [PFQuery queryWithClassName:@"Project"];
            [postQuery whereKey:@"objectId" equalTo:self.project[@"parseId"]];
            [postQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [object deleteEventually];
            }];
            
            NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Job class])];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", self.project[@"objectId"]];
            [request setPredicate:predicate];
            
            NSError *error;
            Job *job = [[context executeFetchRequest:request error:&error] objectAtIndex:0];

            if (job == nil) {
                NSLog(@"Error: %@", error);
            }
            
            [context deleteObject:job];
            if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    else if ([actionSheet.title isEqualToString:@"Complete Project"]) {
        NSLog(@"complete button clicked");
        if (buttonIndex == 1) {
            PFQuery *postQuery = [PFQuery queryWithClassName:@"Project"];
            [postQuery whereKey:@"objectId" equalTo:self.project[@"parseId"]];
            [postQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                object[@"completed"] = [NSNumber numberWithBool:YES];
                [object saveInBackground];
            }];
            
            NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Job class])];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", self.project[@"objectId"]];
            [request setPredicate:predicate];
            
            NSError *error;
            Job *job = [[context executeFetchRequest:request error:&error] objectAtIndex:0];
            job.completed = [NSNumber numberWithBool:YES];

            if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

#pragma mark - delete project

- (IBAction)deleteProject:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Are you sure you want to delete this contract?"  delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes", nil];
    [alert show];
}

#pragma mark - mark as complete

- (IBAction)completeProject:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Complete Project" message:@"Are you sure you want to mark this project as complete?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}


#pragma mark - UITextViewDelegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"[No Notes]"]) {
        textView.text = @"";
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y - self.navigationController.navigationBar.frame.size.height*4)];
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView setUserInteractionEnabled:NO];
    [self.editNotesButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}


#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.titleField) {
        if ([textField.text isEqualToString:@"[Title Not Set]"]) {
            textField.text = @"";
        }
    }
    if (textField == self.priceField) {
        if ([textField.text isEqualToString:@"[Price Not Set]"]) {
            textField.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField setUserInteractionEnabled:NO];
    if (textField == self.titleField) {
        [self.editTitleButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
    else if (textField == self.priceField) {
        float price = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]].floatValue;
        textField.text = [NSString stringWithFormat:@"$%.02f", price];
        [self.editPriceButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField) {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

#pragma mark - edit photo

- (IBAction)editPhoto:(id)sender {
    self.mediaPicker = [[UIImagePickerController alloc] init];
    self.mediaPicker.delegate = (id)self;
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

#pragma mark - UIActionSheet delegate methods

// Action sheet titles are "Date Picker" and nil

-(void)actionSheet:(UIActionSheet *)actionSheet
willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString:@"Date Picker"]) {
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"MM/dd/yyyy"];
        
        [self.dueDate setText:[dateformatter stringFromDate:[self.pickerView date]]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet.title isEqualToString:@"Date Picker"]) {
        return;
    }
    if (buttonIndex == 0) {
        self.mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.mediaPicker animated:YES completion:NULL];
        
//        imagePicker = [[UIImagePickerController alloc] init];
//        [imagePicker setDelegate:self];
//        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
//        [imagePicker setAllowsEditing:YES];
//        
//        [self presentModalViewController:imagePicker animated:YES];
    }
    else if (buttonIndex == 1) {
        self.mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.mediaPicker animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    //        [self.uploadButton setBackgroundImage:image forState:UIControlStateNormal];
//    [self.uploadButton setImage:image  forState:UIControlStateNormal];
//    self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if (self.mediaPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //        [self.uploadButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.picture setImage:image forState:UIControlStateNormal];
        self.picture.imageView.contentMode = UIViewContentModeScaleAspectFill;
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
            [self.picture setImage:copyOfOriginalImage forState:UIControlStateNormal];
            //            [self.uploadButton setBackgroundImage:copyOfOriginalImage forState:UIControlStateNormal];
            self.picture.imageView.contentMode = UIViewContentModeScaleAspectFill;
            //            UIViewContentModeScaleAspectFill;
            //            UIViewContentModeCenter
        }
        failureBlock:^(NSError *error) {
                    // error handling
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
