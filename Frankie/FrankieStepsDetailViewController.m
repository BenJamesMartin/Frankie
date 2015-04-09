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

@interface FrankieStepsDetailViewController ()

@end

@implementation FrankieStepsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    
    FrankieStepsDetailViewController *svc = (FrankieStepsDetailViewController *)[self.navigationController.viewControllers lastObject];
    
    NSIndexPath *tableSelection = [svc.tableView indexPathForSelectedRow];
    FrankieStepsTableViewCell *cell = (FrankieStepsTableViewCell *)[svc.tableView cellForRowAtIndexPath:tableSelection];
    
    if (self.nameField != nil) {
        cell.name.text = self.nameField.text;
    }
    if (self.dueDateField != nil) {
        cell.dueDate.text = self.dueDateField.text;
    }
    if (self.hasSelectedImage) {
        cell.picture.image = self.uploadButton.imageView.image;
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
    if (textField.tag == 0) {
        self.nameField = textField;
    }
    if (textField.tag == 1) {
        self.dueDateField = textField;
        [self showDatePicker];
    }
}


#pragma mark - Date picker

// Change this to UIAlertController
- (void)showDatePicker
{
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    
    [dateSelectionVC setSelectButtonAction:^(RMDateSelectionViewController *controller, NSDate *date) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MMMM dd, yyyy";
        self.dueDateField.text = [formatter stringFromDate:date];
    }];
    
    [dateSelectionVC setCancelButtonAction:^(RMDateSelectionViewController *controller) {
    }];
    
    [self presentViewController:dateSelectionVC animated:YES completion:nil];
}

- (IBAction)choosePhoto:(id)sender {
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
