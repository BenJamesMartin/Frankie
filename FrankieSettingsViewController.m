//
//  FrankieSettingsViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/4/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

#import "FrankieSettingsViewController.h"
#import "FrankieAppDelegate.h"

@interface FrankieSettingsViewController ()

@end

@implementation FrankieSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Show/hide keyboard
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(keyboardDismiss)
                   name:UIKeyboardWillHideNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(keyboardShow)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger-icon"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(revealLeftMenu)];

    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    // If it has been set, load it
    // If it hasn't been set, it will be set later
    
    NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Contractor class])];
    request.predicate = [NSPredicate predicateWithFormat:@"parseId = %@", self.contractor.objectID];
    request.fetchLimit = 1;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    self.contractor = fetchedObjects[0];
    
    NSLog(@"self.contractor %@", self.contractor);
    
//    if (self.contractor != nil) {
//        NSData *imageData;
//        
//        if (!([[self.profileImage imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"profile-default"]])) {
//            UIImage *image = [self.profileImage imageForState:UIControlStateNormal];
//            imageData = UIImageJPEGRepresentation(image, 0.9f);
//            [entity setValue:imageData forKey:@"picture"];
//        }
//        if (self.nameField.text.length > 0)
//            [entity setValue:self.nameField.text forKey:@"name"];
//        if (self.phoneField.text.length > 0)
//            [entity setValue:self.phoneField.text forKey:@"phone"];
//        if (self.emailField.text.length > 0)
//            [entity setValue:self.emailField.text forKey:@"email"];
//
//    }
//    
//    if (self.contractor != nil) {
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Contractor class])];
//        request.predicate = [NSPredicate predicateWithFormat:@"SELF = %@", self.contractor.objectID];
//        request.fetchLimit = 1;
//        NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
//        self.contractor = fetchedObjects[0];
//        
//        [self.job setValue:self.projectTitle.text forKey:@"title"];
//        NSString *priceStr =[self.price.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
//        priceStr = [priceStr stringByReplacingOccurrencesOfString:@"," withString:@""];
//        float price = [priceStr floatValue];
//        [self.job setValue:[NSNumber numberWithFloat:price] forKey:@"price"];
//        [self.job setValue:self.steps forKey:@"steps"];
//        [self.job setValue:self.clientInformation forKey:@"clientInformation"];
//        [self.job setValue:self.locationPlacemark forKey:@"location"];
//        [self.job setValue:self.notes forKey:@"notes"];
//        [self.job setValue:[NSNumber numberWithBool:NO] forKeyPath:@"completed"];
//        [self.job setValue:[[[(NSManagedObject*)self.job objectID] URIRepresentation] absoluteString] forKey:@"objectId"];
//        
//        NSData *imageData;
//        // If an image has been uploaded (the image upload button's image is not the defaul upload icon)
//        if (!([[self.uploadButton imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"image-upload-icon"]])) {
//            UIImage *image = [self.uploadButton imageForState:UIControlStateNormal];
//            imageData = UIImageJPEGRepresentation(image, 0.9f);
//            [self.job setValue:imageData forKey:@"picture"];
//        }
//        else {
//            imageData = nil;
//        }
//        
//        if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
//        }
//    }
}

- (void)revealLeftMenu
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"revealSideMenu" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    
    NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Contractor class]) inManagedObjectContext:context];
    
    [entity setValue:[PFUser currentUser].objectId forKey:@"parseId"];
    
    NSData *imageData;
    if (!([[self.profileImage imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"profile-default"]])) {
        UIImage *image = [self.profileImage imageForState:UIControlStateNormal];
        imageData = UIImageJPEGRepresentation(image, 0.9f);
        [entity setValue:imageData forKey:@"picture"];
    }
    if (self.nameField.text.length > 0)
        [entity setValue:self.nameField.text forKey:@"name"];
    if (self.phoneField.text.length > 0)
        [entity setValue:self.phoneField.text forKey:@"phone"];
    if (self.emailField.text.length > 0)
        [entity setValue:self.emailField.text forKey:@"email"];

    if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%lu", indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}


#pragma mark - Keyboard dismissal

-(void)keyboardShow
{
    for (UIView *view in @[self.view]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismissTap)];
        [view addGestureRecognizer:tap];
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, -200, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)keyboardDismiss {
    for (UIView *view in @[self.view]) {
        for (UIGestureRecognizer *gr in [view gestureRecognizers]) {
            if ([gr class] == [UITapGestureRecognizer class]) {
                [view removeGestureRecognizer:gr];
            }
        }
    }
    [UIView animateWithDuration:0.50 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)keyboardDismissTap {
    [self.view endEditing:YES];
}


#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 0)
        self.nameField = textField;
    else if (textField.tag == 1)
        self.phoneField = textField;
    else
        self.emailField = textField;
    
    NSLog(@"textFieldDidBeginEditing");
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, -200, self.view.frame.size
                                     .width, self.view.frame.size.height);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing");
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size
                                     .width, self.view.frame.size.height);
    }];
}


#pragma mark - Phone number editing

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag != 1)
        return YES;
    
    int length = [self getLength:textField.text];
    
    if(length == 10)
    {
        if(range.length == 0)
            return NO;
    }
    
    if(length == 3)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"%@-",num];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@-",[num substringToIndex:3]];
    }
    else if(length == 6)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"%@-%@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@-%@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    if (length > 10) {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    
    return mobileNumber;
}


-(int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
}


# pragma mark - UIImagePickerController delegate methods

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // For updating profile image in side menu
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    
    if (self.mediaPicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        userInfo[@"image"] = image;
        self.profileImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.profileImage setImage:image forState:UIControlStateNormal];
    }
    else {
        NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
            userInfo[@"image"] = image;
            self.profileImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.profileImage setImage:image forState:UIControlStateNormal];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeProfilePicture" object:nil userInfo:userInfo];
        }
        failureBlock:^(NSError *error) {
            // error handling
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44; // Default height
}


- (IBAction)changeProfileImage:(id)sender {
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
