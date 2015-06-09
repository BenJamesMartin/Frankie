//

//  FrankieAddContractViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 1/20/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Parse/Parse.h>
#import <UITextField+Shake/UITextField+Shake.h>

#import "FrankieAddEditContractViewController.h"
#import "FrankieDetailProjectViewController.h"
#import "FrankieProjectManager.h"
#import "FrankieAppDelegate.h"
#import "ProjectStep.h"
#import "Project.h"
#import "RTNActivityView.h"

@interface FrankieAddEditContractViewController ()

@property (strong, nonatomic) NSMutableArray *cellLabels;

@end

@implementation FrankieAddEditContractViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom init
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellLabels = [NSMutableArray new];
    
    self.shouldSetJobInViewDidAppear = YES;
    
    // If we're not editing an existing job, we're creating a new one. Add a cancel button in the top-left.
    if (self.project == nil) {
        // Set left bar button item (Cancel button)
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelCreation)];
        // Reset current project
        [FrankieProjectManager sharedManager].currentProject = nil;
        
        self.navigationItem.leftBarButtonItem = backItem;
    }
    // If we're editing the job, change the back button title to a more appropriate "Done"
    // Also load data for the project
    else {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(createOrEditProject:)];
        
        self.project = [FrankieProjectManager sharedManager].currentProject;
        [self.buildProjectButton setTitle:@"Save" forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = backItem;
    }

    if ([self.project.title isEqualToString:@""] || self.project.title == nil) {
        self.navigationItem.title = @"New Project";
    }
    else {
        self.navigationItem.title = self.project.title;
    }
    
    [self.uploadButton setImage:[UIImage imageNamed:@"image-upload-icon.png"] forState:UIControlStateNormal];
    self.steps = [NSMutableArray new];

    self.projectHasBeenEdited = NO;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardDismiss)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(keyboardShown:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    
    [self loadData];
}

- (void)doneEditing
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [UIView setAnimationsEnabled:YES];
    
    // Remove the current selection in our table view
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    // If editing an existing project, load project image
    NSData *imageData = self.project.picture;
    if (imageData != nil) {
        UIImage *image = [UIImage imageWithData:imageData];
        self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.uploadButton setImage:image forState:UIControlStateNormal];
    }
    
    if (self.isCreatingFirstStep && self.steps.count > 0) {
        if (self.svc == nil) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.svc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieStepsViewController"];
        }
        [self.svc.view endEditing:YES];
        self.svc.steps = self.steps;
        [self.navigationController pushViewController:self.svc animated:NO];
        self.isCreatingFirstStep = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    // Regardless of whether we're loading data for an existing contract, create references to the title and price text fields on the table view
    [self createTextFieldsReferences];
    
    // If we're navigating back from steps VC, we should not write over steps.
    if (self.project != nil && self.shouldSetJobInViewDidAppear) {
        self.steps = self.project.steps;
        self.shouldSetJobInViewDidAppear = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // If we're editing an existing project, set project of detail project VC
    if ([self.navigationController.viewControllers.lastObject isKindOfClass:FrankieDetailProjectViewController.class]) {
        FrankieDetailProjectViewController *dpvc = self.navigationController.viewControllers.lastObject;
        dpvc.project = self.project;
    }
}


#pragma mark - Load data for existing project

- (void)createTextFieldsReferences
{
    NSIndexPath *path0 = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *path1 = [NSIndexPath indexPathForRow:1 inSection:0];
    
    UITableViewCell *cell0 = [self.tableView cellForRowAtIndexPath:path0];
    UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:path1];
    
    for (UIView *subview in cell0.contentView.subviews) {
        if (subview.tag == 1) {
            UITextField *tf = (UITextField *)subview;
            self.projectTitle = tf;
            if (self.project.title != nil) {
                tf.text = self.project.title;
                tf.alpha = 0.0;
                [UIView animateWithDuration:0.5 animations:^{
                    tf.alpha = 1.0;
                }];
            }
        }
    }
    
    for (UIView *subview in cell1.contentView.subviews) {
        if (subview.tag == 2) {
            UITextField *tf = (UITextField *)subview;
            self.price = tf;
            if (self.project.price != nil) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
                numberFormatter.maximumFractionDigits = 0;
                NSString *currencyString = [numberFormatter stringFromNumber:self.project.price];
                if (self.project.price.floatValue != 0)
                    tf.text = currencyString;
                tf.alpha = 0.0;
                [UIView animateWithDuration:0.5 animations:^{
                    tf.alpha = 1.0;
                }];
            }
        }
    }

}

- (void)loadData
{
    // Create reference to proper cells
    // Doesn't work properly because not all are visible
    
    // Add null as a placeholder for any fields that haven't been set. This preserves the mapping of label to table view cell. When text is being set in cellForRow, will not set if equal to null.
    
    NSArray *steps = self.project.steps;
    if (steps.count > 0) {
        UILabel *stepsLabel = [UILabel new];
        if (steps.count == 1)
            stepsLabel.text = [NSString stringWithFormat:@"%lu Step   ", steps.count];
        else
            stepsLabel.text = [NSString stringWithFormat:@"%lu Steps   ", steps.count];
        stepsLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
        stepsLabel.textColor = [UIColor darkGrayColor];
        [stepsLabel sizeToFit];
        
        [self.cellLabels addObject:stepsLabel];
    }
    else {
        [self.cellLabels addObject:[NSNull null]];
    }
    
    NSDictionary *clientInformation = self.project.clientInformation;
    if (clientInformation != nil && clientInformation.allKeys.count > 0) {
        UILabel *clientInfoLabel = [UILabel new];
        clientInfoLabel.text = [NSString stringWithFormat:@"%@", clientInformation[@"name"]];
        clientInfoLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
        clientInfoLabel.textColor = [UIColor darkGrayColor];
        [clientInfoLabel sizeToFit];
        
        [self.cellLabels addObject:clientInfoLabel];
    }
    else {
        [self.cellLabels addObject:[NSNull null]];
    }
    
    CLPlacemark *placemark = self.project.location;
    if (placemark != nil) {
        UILabel *locationLabel = [UILabel new];
        locationLabel.text = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
        locationLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
        locationLabel.textColor = [UIColor darkGrayColor];
        [locationLabel sizeToFit];
        
        [self.cellLabels addObject:locationLabel];
    }
    else {
        [self.cellLabels addObject:[NSNull null]];
    }
    
    NSString *notes = self.project.notes;
    if (notes != nil) {
        if (notes.length > 0) {
            NSArray *words = [notes componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSMutableString *mutableNotes = [[NSMutableString alloc] initWithString:@""];
            
            for (int i = 0; i < words.count; i++) {
                [mutableNotes appendString:words[i]];
                if (i != words.count - 1)
                    [mutableNotes appendString:@" "];
                if (i == 2)
                    break;
            }
            [mutableNotes appendString:@"...   "];
            
            UILabel *notesLabel = [UILabel new];
            notesLabel.text = mutableNotes;
            notesLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
            notesLabel.textColor = [UIColor darkGrayColor];
            [notesLabel sizeToFit];
            if (notesLabel.frame.size.width > 135) {
                notesLabel.frame = CGRectMake(notesLabel.frame.origin.x, notesLabel.frame.origin.y, 135, notesLabel.frame.size.height);
            }
            
            [self.cellLabels addObject:notesLabel];
        }
    }
    else {
        [self.cellLabels addObject:[NSNull null]];
    }
}

- (void)cancelCreation
{
    if (self.projectHasBeenEdited) {
        UIAlertController *cancelController = [UIAlertController alertControllerWithTitle:@"Cancel Upload?" message:@"Cancel the creation of this project?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        
        [cancelController addAction:confirm];
        [cancelController addAction:cancel];
        
        [self presentViewController:cancelController animated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// Adds gesture recognizer to image upload button so can be tapped to dismiss keyboard
- (void)keyboardShown:(NSNotification *)notification
{
    // Get the keyboard height and adjust the view to accomodate the keyboard
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat kbHeight = kbSize.height;
    
    [UIView animateWithDuration:0.50 animations:^{
        self.view.frame = CGRectMake(0, -kbHeight, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
    // A single gesture recognizer can only be added to one view, so we need a gesture recognizer for each view.
    for (UIView *view in @[self.view, self.tableView, self.uploadButton]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismissTap)];
        [view addGestureRecognizer:tap];
    }
}

// When the keyboard dismisses, remove the tap gesture recognizer on the scrollView image upload button
- (void)keyboardDismiss {
    // Adjust the view back to its origin when hiding the keyboard
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
    for (UIView *view in @[self.view, self.tableView, self.uploadButton]) {
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

#pragma mark - Create a new contract or edit an existing one

- (IBAction)createOrEditProject:(id)sender
{
    if (self.projectTitle.text.length == 0) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.tableView setContentOffset:CGPointZero animated:NO];
        } completion:^(BOOL finished) {
            [self.projectTitle shake:10 withDelta:7 speed:0.03 completion:^{
            }];
        }];
        return;
    }
    
    NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    // Edit existing contract
    if (self.project != nil) {
        // Fetch object from Core Data
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Project class])];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF = %@", self.project.objectID];
        request.fetchLimit = 1;
        NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
        self.project = fetchedObjects[0];
        
        [self.project setValue:self.projectTitle.text forKey:@"title"];
        NSString *priceStr = [self.price.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        priceStr = [priceStr stringByReplacingOccurrencesOfString:@"," withString:@""];
        float price = [priceStr floatValue];
        [self.project setValue:self.steps forKey:@"steps"];
        [self.project setValue:[NSNumber numberWithFloat:price] forKey:@"price"];
        [self.project setValue:[NSNumber numberWithBool:NO] forKeyPath:@"completed"];
        [self.project setValue:[[[(NSManagedObject*)self.project objectID] URIRepresentation] absoluteString] forKey:@"objectId"];
        
        NSData *imageData;
        // If an image has been uploaded (the image upload button's image is not the defaul upload icon)
        if (!([[self.uploadButton imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"image-upload-icon"]])) {
            UIImage *image = [self.uploadButton imageForState:UIControlStateNormal];
            imageData = UIImageJPEGRepresentation(image, 0.9f);
            [self.project setValue:imageData forKey:@"picture"];
        }
        else {
            imageData = nil;
        }
        
        if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
        }
    }
    // Add new contract
    else {
        // Store new contract in Core Data
        NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Project class]) inManagedObjectContext:context];
        
        [entity setValue:self.projectTitle.text forKey:@"title"];
        NSString *priceStr = [self.price.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        priceStr = [priceStr stringByReplacingOccurrencesOfString:@"," withString:@""];
        float price = [priceStr floatValue];
        [entity setValue:[NSNumber numberWithFloat:price] forKey:@"price"];
        [entity setValue:self.steps forKey:@"steps"];
        [entity setValue:self.clientInformation forKey:@"clientInformation"];
        [entity setValue:self.locationPlacemark forKey:@"location"];
        [entity setValue:self.notes forKey:@"notes"];
        [entity setValue:[NSNumber numberWithBool:NO] forKeyPath:@"completed"];
        [entity setValue:[[[(NSManagedObject*)entity objectID] URIRepresentation] absoluteString] forKey:@"objectId"];
        [entity setValue:[NSDate date] forKey:@"createdAt"];
        
        NSData *imageData;
        if (!([[self.uploadButton imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"image-upload-icon"]])) {
            UIImage *image = [self.uploadButton imageForState:UIControlStateNormal];
            imageData = UIImageJPEGRepresentation(image, 0.9f);
            [entity setValue:imageData forKey:@"picture"];
        }
        else {
            imageData = nil;
        }

        // Parse remote storage
        //    PFObject *project = [PFObject objectWithClassName:@"Project"];
        //    project[@"user"] = [PFUser currentUser];
        //    if (imageData != nil) {
        //        project[@"photo"] = [PFFile fileWithData:imageData];
        //    }
        //    project[@"title"] = self.projectTitle.text;
        //    project[@"price"] = [NSNumber numberWithInt:[self.price.text integerValue]];
        //    project[@"steps"] = self.steps;
        //    project[@"clientInformation"] = self.clientInformation;
        //    project[@"location"] = self.locationPlacemark;
        //    project[@"completed"] = [NSNumber numberWithBool:NO];
        //    project[@"notes"] = self.notes;
        //
        //    project.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        //
        //    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        //        if (!error) {
        //            [entity setValue:[project objectId] forKeyPath:@"parseId"];
//                    if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
//                    }
        //        }
        //    }];
        
        if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
        }
    }

    // Now the Core Data object has been added, return back to master VC where the fetched results controller will take care of updating its table view.
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Select image button tapped

- (IBAction)choosePhoto:(id)sender
{
    self.projectHasBeenEdited = YES;
    
    self.mediaPicker = [UIImagePickerController new];
    [self.mediaPicker setDelegate:self];
    self.mediaPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *uploadPhotoController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.mediaPicker animated:YES completion:NULL];
        }];
        UIAlertAction *chooseExisting = [UIAlertAction actionWithTitle:@"Choose Existing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.mediaPicker animated:YES completion:NULL];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [uploadPhotoController addAction:takePhoto];
        [uploadPhotoController addAction:chooseExisting];
        [uploadPhotoController addAction:cancel];
        
        [self presentViewController:uploadPhotoController animated:YES completion:nil];
    }
    else {
        self.mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.mediaPicker animated:YES completion:NULL];
    }
}


# pragma mark - UIImagePickerController delegate methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField) {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Set text fields as properties
    if (textField.tag == 1) {
        self.projectTitle = textField;
    }
    if (textField.tag == 2) {
        self.price = textField;
    }
    
    // Remove currency formatting from number
    if (textField.tag == 2 && textField.text.length > 0) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *replacedText = [textField.text stringByReplacingOccurrencesOfString:formatter.internationalCurrencySymbol withString:@""];
        float fval = [formatter numberFromString:replacedText].floatValue;
        textField.text = [NSString stringWithFormat:@"%.0f", fval];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Add currency formatting to price field
    if (textField.tag == 2) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *currency = [f numberFromString:textField.text];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        numberFormatter.maximumFractionDigits = 0;
        NSString *currencyString = [numberFormatter stringFromNumber:currency];
        textField.text = currencyString;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.projectHasBeenEdited = YES;
    
    // If the textField is the price textField, don't let the length of the price textField exceed six numbers
    if (textField.tag == 2) {
        if (range.length + range.location > textField.text.length) {
            return NO;
        }
        
        NSUInteger newLength = textField.text.length + string.length - range.length;
        return (newLength > 7) ? NO : YES;
    }
    return YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%lu", indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // Only set cell labels for cells after price label
    if (indexPath.row > 1) {
        // Check to see if the object is null
        if (![[self.cellLabels objectAtIndex:indexPath.row - 2] isEqual:[NSNull null]]) {
            UILabel *label = [self.cellLabels objectAtIndex:indexPath.row - 2];
            cell.accessoryView = label;
        }
    }
    
    // Store a reference to the steps cell for manipulation in other view controllers
    if (indexPath.row == 2) {
        self.stepsCell = cell;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

// Manually perform navigation controller push to keep reference to each VC
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.projectHasBeenEdited = YES;
    
    [self.view endEditing:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // Steps
    if (indexPath.row == 2) {
        // If no steps have been created yet, navigate directly to add/edit step VC
        if (self.steps.count == 0) {
            FrankieStepsDetailViewController *sdvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieStepsDetailViewController"];
            [sdvc.view endEditing:YES];
            self.isCreatingFirstStep = YES;
            sdvc.isFirstStep = YES;
            [self.navigationController pushViewController:sdvc animated:YES];
        }
        // If at least one step has been created, navigate to master step VC to view all steps
        else {
            if (self.svc == nil) {
                self.svc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieStepsViewController"];
            }
            [self.svc.view endEditing:YES];
            self.svc.steps = self.steps.mutableCopy;
            [self.navigationController pushViewController:self.svc animated:YES];
        }
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
    // Notes
    else if (indexPath.row == 5) {
        if (self.nvc == nil) {
            self.nvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieNotesViewController"];
        }
        [self.navigationController pushViewController:self.nvc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44; // Default height
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor colorWithRed:210/255.f green:210/255.f blue:210/255.f alpha:1.0];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor colorWithRed:210/255.f green:210/255.f blue:210/255.f alpha:1.0];
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @" ";
}



@end
