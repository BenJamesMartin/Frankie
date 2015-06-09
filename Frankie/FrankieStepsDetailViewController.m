//
//  FrankieStepsDetailViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/7/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <RMDateSelectionViewController/RMDateSelectionViewController.h>
#import "FrankieStepManager.h"
#import "FrankieAddEditContractViewController.h"
#import "FrankieStepsDetailViewController.h"
#import "FrankieStepsViewController.h"
#import "FrankieStepsTableViewCell.h"
#import "FrankieAppDelegate.h"
#import "FrankieDetailProjectViewController.h"


@interface FrankieStepsDetailViewController ()

@end

@implementation FrankieStepsDetailViewController


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];


    self.hasChangedBackButton = NO;
    // Editing existing step - load its data
    if (self.step != nil) {
        [self loadStep];
        [self editLeftBarButtonItemWithTitle:@"Save"];
        self.hasChangedBackButton = YES;
        self.navigationItem.title = self.step.name;
    }
    // Creating a new step
    else {
        self.step =  [[FrankieStepManager sharedManager] newStep];
        self.navigationItem.title = @"New Step";
    }

    self.stepHasBeenEdited = NO;
    
    // Scroll up/down on showing/hiding keyboard
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardDismiss)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(keyboardShown:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Make sure this is happening when dismissing detail view and not when presenting image picker (in which case this VC would be found in the stack of view controllers).
    // If this VC is disappearing and the step has been edited, save it to the model via creating or updating
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound && self.stepHasBeenEdited) {
        // Check if new object should be added to steps model by checking if name property has been set.
        // If name has already been set, this is an existing step and should not be added again.
        BOOL shouldAddNewObject = YES;
        if ([self.step nameHasBeenSet]) {
            shouldAddNewObject = NO;
        }
        [self.view endEditing:YES];
        
        // Regardless of whether editing or creating new step, set Step model properties (name, dueDate, picture)
        // In order to prevent creating an extra property:
        // dueDate set in date picker callback
        // picture set in image picker callback
        if (self.nameField.text.length > 0)
            self.step.name = self.nameField.text;
        
        // If the user is creating the first step, we're navigating from the add/edit VC
        if ([self.navigationController.viewControllers.lastObject class] == [FrankieAddEditContractViewController class]) {
            FrankieAddEditContractViewController *aevc = self.navigationController.viewControllers.lastObject;
            NSIndexPath *indexPath = [aevc.tableView indexPathForSelectedRow];
            UITableViewCell *cell = [aevc.tableView cellForRowAtIndexPath:indexPath];
            
            UILabel *label = [UILabel new];
            label.text = @"1 Step";
            label.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
            label.textColor = [UIColor darkGrayColor];
            [label sizeToFit];
            cell.accessoryView = label;
            
            if (shouldAddNewObject) {
                [aevc.steps addObject:self.step];
            }
        }
        // If the user is creating subsequent steps or editing an existing step, we're navigating from the step master VC
        else if ([self.navigationController.viewControllers.lastObject class] == [FrankieStepsViewController class]) {
            FrankieStepsViewController *svc = (FrankieStepsViewController *)[self.navigationController.viewControllers lastObject];
            NSIndexPath *path = [svc.tableView indexPathForSelectedRow];
            FrankieStepsTableViewCell *cell = (FrankieStepsTableViewCell *)[svc.tableView cellForRowAtIndexPath:path];
            
            // If editing an already existing step, change the cell's contents corresponding to the step
            if (cell != nil) {
                cell.name.text = self.step.name;
                cell.dueDate.text = self.dueDateField.text;
                if (self.step.picture != nil) {
                    cell.picture.image = self.step.picture;
                }
                else {
                    cell.picture.image = [UIImage imageNamed:@"image-upload-icon-small"];
                }
            }
            
            if (shouldAddNewObject)
                [svc.steps addObject:self.step];
        }
        // Else we're adding a first step and navigating back to project detail VC
        else {
            FrankieDetailProjectViewController *dpvc = (FrankieDetailProjectViewController *)self.navigationController.viewControllers.lastObject;
            
            // Get a copy of relevant Core Data project
            NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Project class])];
            request.predicate = [NSPredicate predicateWithFormat:@"SELF = %@", dpvc.project.objectID];
            request.fetchLimit = 1;
            NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
            Project *job = fetchedObjects[0];
            [job setValue:@[self.step] forKey:@"steps"];
            
            // Save the Core Data context
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
                }
            });
        }
        
        // If a date was not set, add the default date (one month from current date as specified in ProjectStep init method) to the date text field
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MMMM dd, yyyy";
        self.dueDateField.text = [formatter stringFromDate:self.step.dueDate];
    }
}


#pragma mark - View scrolling for keyboard

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
    for (UIView *view in @[self.view, self.tableView, self.uploadButton, self.dueDateField]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismissTap)];
        [view addGestureRecognizer:tap];
    }
}

// When the keyboard dismisses, remove the tap gesture recognizer on the scrollView image upload button
- (void)keyboardDismiss
{
    // Adjust the view back to its origin when hiding the keyboard
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
    for (UIView *view in @[self.view, self.tableView, self.uploadButton, self.dueDateField]) {
        for (UIGestureRecognizer *gr in [view gestureRecognizers]) {
            if ([gr class] == [UITapGestureRecognizer class]) {
                [view removeGestureRecognizer:gr];
            }
        }
    }
}

- (void)keyboardDismissTap
{
    [self.view endEditing:YES];
}


#pragma mark - Navigation bar left button & action

- (void)editLeftBarButtonItemWithTitle:(NSString *)title
{
    if (![self.navigationItem.leftBarButtonItem.title isEqualToString:title]) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(createOrEditStep)];
        
        [self.navigationItem setLeftBarButtonItem:item animated:YES];
    }
}

- (void)createOrEditStep
{
    // Animate the view controller transition if this is not the first step.
    BOOL willAnimate = (self.isFirstStep ? NO : YES);
    [self.navigationController popViewControllerAnimated:willAnimate];
}


#pragma mark - Loading an existing step

- (void)loadStep
{
    self.nameField.text = self.step.name;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MMMM dd, yyyy";
    self.dueDateField.text = [formatter stringFromDate:self.step.dueDate];
    if (self.step.picture != nil) {
        self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.uploadButton setImage:[UIImage imageWithData:self.step.picture] forState:UIControlStateNormal];
    }
    else {
        [self.uploadButton setImage:[UIImage imageNamed:@"image-upload-icon"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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


#pragma mark - Table view delegate

// No cells can be selected in this view controller
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44; // Default height
}


#pragma mark - Table view header/footer views

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


#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.dueDateField) {
        [self showDatePicker];
        [textField resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // If creating a new step, information has just been added to it. It can now be created instead of discarded.
    if (!self.hasChangedBackButton) {
        [self editLeftBarButtonItemWithTitle:@"Create"];
    }
    self.stepHasBeenEdited = YES;
    if ([self.step.name isEqualToString:@"[Step Name]"]) {
        [UIView animateWithDuration:0.5 animations:^{
            self.createButton.alpha = 1.0;
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Date picker

- (void)showDatePicker
{
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    
    [dateSelectionVC setSelectButtonAction:^(RMDateSelectionViewController *controller, NSDate *date) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MMMM dd, yyyy";
        self.dueDateField.text = [formatter stringFromDate:date];
        self.step.dueDate = date;
    }];
    
    [dateSelectionVC setCancelButtonAction:^(RMDateSelectionViewController *controller) {
    }];
    
    [self presentViewController:dateSelectionVC animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)choosePhoto:(id)sender
{
    if (!self.hasChangedBackButton) {
        [self editLeftBarButtonItemWithTitle:@"Create"];
    }
    if ([self.step.name isEqualToString:@"[Step Name]"]) {
        [UIView animateWithDuration:0.5 animations:^{
            self.createButton.alpha = 1.0;
        }];
    }
    self.stepHasBeenEdited = YES;
    
    self.mediaPicker = [UIImagePickerController new];
    self.mediaPicker.delegate = self;
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
            [self setNavigationBarTextColor:[UIColor darkGrayColor]];
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
        [self setNavigationBarTextColor:[UIColor darkGrayColor]];
    }
}


# pragma mark - UIImagePickerController delegate methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self setNavigationBarTextColor:[UIColor whiteColor]];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.hasSelectedImage = YES;
    UIImage *image;
    
    // Resize image for display in step cells (in steps VC and project detail VC) on background thread
    void (^completionBlock)(UIImage *) = ^void(UIImage *image) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIGraphicsBeginImageContext(CGSizeMake(50, 50));
            [image drawInRect:CGRectMake(0, 0, 50, 50)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.step.thumbnail = UIImagePNGRepresentation(newImage);
        });
    };
    
    // If using camera
    if (self.mediaPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.uploadButton setImage:image forState:UIControlStateNormal];
        completionBlock(image);
    }
    // Else using photo library
    else {
        NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            UIImage *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
            self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.uploadButton setImage:copyOfOriginalImage forState:UIControlStateNormal];
            self.step.picture = UIImagePNGRepresentation(copyOfOriginalImage);
            completionBlock(copyOfOriginalImage);
        }
            failureBlock:^(NSError *error) {
                // error handling
            }];
    }
    
    [self setNavigationBarTextColor:[UIColor whiteColor]];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Change navigation bar title/bar button item colors

- (void)setNavigationBarTextColor:(UIColor *)color
{
    NSDictionary *barAppearanceDict = @{
                                        NSFontAttributeName : [UIFont fontWithName:@"Avenir-Medium" size:19.0],
                                        NSForegroundColorAttributeName: color
                                        };
    [[UINavigationBar appearance] setTitleTextAttributes:barAppearanceDict];
    
    // Set navigation title color
    NSDictionary *barButtonAppearanceDict = @{
                                              NSFontAttributeName : [UIFont fontWithName:@"Avenir-Light" size:16.0],
                                              NSForegroundColorAttributeName: color
                                              };
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    
    // Set status bar color appropriately
    if ([color isEqual:[UIColor whiteColor]]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
}


#pragma mark - Create Step button action

- (IBAction)createStep:(id)sender
{
    // Animate the view controller transition if this is not the first step.
    BOOL willAnimate = (self.isFirstStep ? NO : YES);
    [self.navigationController popViewControllerAnimated:willAnimate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
