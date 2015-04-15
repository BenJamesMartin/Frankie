//
//  FrankieStepsDetailViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/7/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <RMDateSelectionViewController/RMDateSelectionViewController.h>

#import "FrankieStepsDetailViewController.h"
#import "FrankieStepsViewController.h"
#import "FrankieStepsTableViewCell.h"

#import "ProjectStep.h"

@interface FrankieStepsDetailViewController ()

@end

@implementation FrankieStepsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.hasChangedBackButton = NO;
    // Editing existing step - load its data
    if (self.step != nil) {
        [self loadStep];
        [self editLeftBarButtonItemWithTitle:@"Done"];
        self.hasChangedBackButton = YES;
    }
    // Creating a new step
    else {
        self.step = [ProjectStep new];
    }

    self.stepHasBeenEdited = NO;
}

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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadStep
{
    self.nameField.text = self.step.name;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MMMM dd, yyyy";
    self.dueDateField.text = [formatter stringFromDate:self.step.dueDate];
    if (self.step.picture != nil) {
        self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.uploadButton setImage:self.step.picture forState:UIControlStateNormal];
    }
    else {
        [self.uploadButton setImage:[UIImage imageNamed:@"image-upload-icon"] forState:UIControlStateNormal];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Make sure this is happening when dismissing detail view and not when presenting image picker
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound && self.stepHasBeenEdited) {
        
        // Check if object should be added to steps model by checking if name property has been set.
        BOOL shouldAddObject = YES;
        if ([self.step nameHasBeenSet]) {
            shouldAddObject = NO;
        }
        [self.view endEditing:YES];
        
        // Regardless of whether editing or creating new step, set Step model properties (name, dueDate, picture)
        // In order to prevent creating an extra property:
        // dueDate set in date picker callback
        // picture set in image picker callback
        if (self.nameField.text.length > 0)
            self.step.name = self.nameField.text;
        
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
        
        // If a date was not set, add the default date (one month from current date as specified in ProjectStep init method) to the date text field
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MMMM dd, yyyy";
        self.dueDateField.text = [formatter stringFromDate:self.step.dueDate];
        
        // Reset shouldAddStep flag and verify that we are navigating back to master view from this view (step detail) versus its parent view (add project VC)
        if (shouldAddObject)
            [svc.steps addObject:self.step];
    }
}


#pragma mark - UITableViewDataSource

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


#pragma mark - UITableViewDelegate

// No cells can be selected in this view controller
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44; // Default height
}


#pragma mark - UITextField delegate

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

- (IBAction)choosePhoto:(id)sender {
    if (!self.hasChangedBackButton) {
        [self editLeftBarButtonItemWithTitle:@"Create"];
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

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.hasSelectedImage = YES;
    if (self.mediaPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.uploadButton setImage:image forState:UIControlStateNormal];
        self.step.picture = image;
    }
    else {
        NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            UIImage  *copyOfOriginalImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
            self.uploadButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.uploadButton setImage:copyOfOriginalImage forState:UIControlStateNormal];
            self.step.picture = copyOfOriginalImage;
        }
            failureBlock:^(NSError *error) {
                // error handling
            }];
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
