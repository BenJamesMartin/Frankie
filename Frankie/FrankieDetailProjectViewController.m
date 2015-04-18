//
//  FrankieDetailProjectViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/14/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <pop/POP.h>
#import <HMSegmentedControl/HMSegmentedControl.h>

#import "FrankieDetailProjectViewController.h"
#import "FrankieAddEditContractViewController.h"
#import "FrankieProjectDetailStepsTableViewCell.h"
#import "RTNActivityView.h"
#import "ProjectStep.h"

@implementation FrankieDetailProjectViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UIBarButtonItem *editProjectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProject)];
    self.navigationItem.rightBarButtonItem = editProjectButton;
    
    self.navigationItem.title = self.job.title;
    [self drawSegmentedControl];
    self.locationView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 312)];
    
    self.reloadDataOnReappear = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 312) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FrankieDetailProjectStepsTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.interchangeableView addSubview:self.tableView];
    
    [self loadProjectData];
    
    // Padding
    self.notes.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.reloadDataOnReappear) {
        [self loadProjectData];
        self.reloadDataOnReappear = NO;
    }
}


#pragma mark - Top-right button for editing project

- (void)editProject
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FrankieAddEditContractViewController *aevc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieAddEditContractViewController"];
    aevc.job = self.job;
    [self.navigationController pushViewController:aevc animated:YES];
    
    self.reloadDataOnReappear = YES;
}


#pragma mark - Load (or reload) project data

- (void)loadProjectData
{
    NSDictionary *clientInformation = self.job.clientInformation;
    NSString *name = clientInformation[@"name"];
    if (name != nil && name.length > 0)
        self.clientName.text = name;
    else
        self.clientName.text = @"[Client Name]";
    
    self.dateRange.text = [self setDateRangeText];
    
    UIImage *image = [UIImage imageWithData:self.job.picture];
    if (image != nil && ![image isEqual:[UIImage imageNamed:@"image-upload-icon"]]) {
        self.image.layer.borderWidth = 0.0;
        self.image.image = image;
    }
    else {
        self.image.image = [UIImage imageNamed:@"image-upload-icon-small"];
        self.image.layer.borderColor = [UIColor colorWithRed:200/255.f green:200/255.f blue:200/255.f alpha:1.0].CGColor;
        self.image.layer.borderWidth = 2.0;
    }
    
    if (self.job.notes != nil && ![self.job.notes isEqualToString:@""])
        self.notes.text = self.job.notes;
    else {
        self.notes.textAlignment = NSTextAlignmentCenter;
        self.notes.text = @"No project notes.";
    }
    
    [self centerOnProjectLocation];
}

- (void)centerOnProjectLocation
{
    CLPlacemark *placemark = self.job.location;
    if (placemark != nil) {
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        span.latitudeDelta = 0.015;
        span.longitudeDelta = 0.015;
        CLLocationCoordinate2D location;
        
        MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
        location.latitude = mkPlacemark.coordinate.latitude;
        location.longitude = mkPlacemark.coordinate.longitude;
        region.span = span;
        region.center = location;
        [self.locationView setRegion:region animated:YES];
        
        self.annotation = [[MKPointAnnotation alloc] init];
        [self.annotation setCoordinate:location];
        [self.annotation setTitle:[NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare]];
        [self.locationView addAnnotation:self.annotation];
    }
}

// Convenience method for calculating date range
- (NSString *)setDateRangeText
{
    NSDate *startDate = self.job.createdAt;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MMMM dd, yyyy";
    NSString *startDateString = [formatter stringFromDate:startDate];
    
    NSArray *steps = self.job.steps;
    if (steps.count > 0) {
        NSDate *latestDueDate = [NSDate date];
        
        // Find project step's latest due date
        for (ProjectStep *step in self.job.steps) {
            // If the step's due date is later, it returns 1 (> 0)
            if ([step.dueDate compare:latestDueDate] > 0)
                latestDueDate = step.dueDate;
        }
        

        NSString *latestDateString = [formatter stringFromDate:latestDueDate];
        
        return [NSString stringWithFormat:@"%@ - %@", startDateString, latestDateString];
    }
    // If there are no steps, simply return creation date
    return [NSString stringWithFormat:@"Created %@", startDateString];
}


#pragma mark - HMSegmentedControl

// Draw the segmented control onto the view
- (void)drawSegmentedControl
{
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Steps", @"Location"]];
    
    [segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor],
              NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:14.0]}];
        return attString;
    }];
    
    // ** --- Font : Segmented Control Profile --- **
    UIColor *lightGrayHeader = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    segmentedControl.frame = CGRectMake(0, 216, self.view.frame.size.width, 40);
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    segmentedControl.selectionIndicatorHeight = 1.0f;
    segmentedControl.selectionIndicatorColor = [UIColor lightGrayColor];
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    segmentedControl.backgroundColor = lightGrayHeader;
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectedSegmentIndex = 0;
    [self.view addSubview:segmentedControl];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    long index = (long)segmentedControl.selectedSegmentIndex;
    
    // Remove current subview ("Items"/"Watching"/"Messages")
    [[self.interchangeableView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Add the subview for the selected segment index
    switch (index) {
        case 0:
            [self.interchangeableView addSubview:self.tableView];
            self.directionsButton.alpha = 0.0;
            self.directionsButton.userInteractionEnabled = NO;
            [self centerOnProjectLocation];
            break;
        case 1:
            [self.interchangeableView addSubview:self.locationView];
            self.directionsButton.alpha = 1.0;
            self.directionsButton.userInteractionEnabled = YES;
            self.noStepsLabel.alpha = 0;
            break;
        default:
            break;
    }
}

- (int)calculateProjectStepCount
{
    NSArray *steps = self.job.steps;
    return (int)steps.count;
}


#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"No project notes."]) {
        textView.text = @"";
        textView.textAlignment = NSTextAlignmentCenter;
    }
}


#pragma mark - Contact client actions

- (IBAction)callClient:(id)sender
{
    NSDictionary *clientInformation = self.job.clientInformation;
    NSString *phoneNumber = clientInformation[@"phone"];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (phoneNumber != nil && phoneNumber.length > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]]];
    else
        [self showAlertControllerWithMessage:@"To call this client, please edit the project and provide the client's phone number."];
}

- (IBAction)emailClient:(id)sender
{
    NSDictionary *clientInformation = self.job.clientInformation;
    NSString *email = clientInformation[@"email"];
    if (email != nil && email.length > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", email]]];
    else
        [self showAlertControllerWithMessage:@"To email this client, please edit the project and provide the client's email."];
}

- (IBAction)textClient:(id)sender
{
    NSDictionary *clientInformation = self.job.clientInformation;
    NSString *phoneNumber = clientInformation[@"phone"];
    if (phoneNumber != nil && phoneNumber.length > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:+%@", phoneNumber]]];
    else
        [self showAlertControllerWithMessage:@"To text this client, please edit the project and provide the client's phone number."];
}

- (void)showAlertControllerWithMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:doneAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *steps = self.job.steps;
    if (steps.count == 0)
        self.noStepsLabel.alpha = 1.0;
    else
        self.noStepsLabel.alpha = 0.0;
    return steps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
 
    FrankieProjectDetailStepsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[FrankieProjectDetailStepsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    return [self configureCell:cell atIndexPath:indexPath];
}

- (FrankieProjectDetailStepsTableViewCell *)configureCell:(FrankieProjectDetailStepsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ProjectStep *step = self.job.steps[indexPath.row];
    
    // Set checkmark image as completed and set date format as "Completed [date]".
    if (step.completed) {
        cell.checkmarkImage.image = [UIImage imageNamed:@"checkmark-filled"];
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MMMM d, yyyy";
        NSString *dateString = [formatter stringFromDate:step.completionDate];
        cell.dueIn.text = [NSString stringWithFormat:@"Completed %@", dateString];
    }
    // Set checkmark image as incomplete and set date format as "DUE IN [X] DAYS".
    else {
        cell.checkmarkImage.image = [UIImage imageNamed:@"checkmark-empty"];
        
        double secondsUntilStepIsDue = [step.dueDate timeIntervalSinceNow];
        int numberOfDays = floor(secondsUntilStepIsDue / 86400);
        cell.dueIn.text = [NSString stringWithFormat:@"DUE IN %d DAYS", numberOfDays];
    }
    
    if (step.picture != nil && ![step.picture isEqual:[UIImage imageNamed:@"image-upload-icon"]])
        cell.picture.image = step.picture;
    else
        cell.picture.image = [UIImage imageNamed:@"image-upload-icon-small"];
    
    cell.name.text = step.name;
    
    return cell;
}

- (void)shakeCell
{
    
}


#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSArray *steps = self.job.steps;
    if (steps.count > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        view.backgroundColor = [UIColor colorWithRed:210/255.f green:210/255.f blue:210/255.f alpha:1.0];
        return view;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *steps = self.job.steps;
    if (steps.count > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        view.backgroundColor = [UIColor colorWithRed:210/255.f green:210/255.f blue:210/255.f alpha:1.0];
        return view;
    }
    return nil;
}


- (IBAction)getDirections:(id)sender
{
    self.hasProvidedDirections = NO;
    // If the user has provided a project location, prompt for their location to obtain directions
    if (self.job.location != nil) {
        CLLocationManager *locationManager = [CLLocationManager new];
        [locationManager startUpdatingLocation];
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        self.locationView.showsUserLocation = YES;
    }
    // If no project location has been provided, inform the user he needs to provide one to obtain directions
    else {
        [self showAlertControllerWithMessage:@"Please edit the project and provide its location to obtain directions."];
    }
}


#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (!self.hasProvidedDirections) {
        CLLocation *location = locations.lastObject;
        CLGeocoder *geocoder = [CLGeocoder new];
        [RTNActivityView show];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            [RTNActivityView hide];
            CLPlacemark *sourcePlacemark = placemarks.lastObject;
            NSString *sourceStreetNumber = sourcePlacemark.subThoroughfare;
            // If Core Location cannot determine the exact street number, it provides a range (e.g. "2203-2217" instead of "2215"). Entering a range into a Maps query will result in no street number being used, resulting in inaccurate directions. Use the lower end of the range to ensure a complete address is provided.
            sourceStreetNumber = [sourceStreetNumber componentsSeparatedByString:@"-"][0];
            NSString *sourceStreetName = sourcePlacemark.thoroughfare;
            sourceStreetName = [sourceStreetName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSString *sourceCity = sourcePlacemark.locality;
            sourceCity = [sourceCity stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSString *sourceState = sourcePlacemark.administrativeArea;
            sourceState = [sourceState stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            CLPlacemark *destinationPlacemark = self.job.location;
            NSString *destinationStreetNumber = destinationPlacemark.subThoroughfare;
            NSString *destinationStreetName = destinationPlacemark.thoroughfare;
            destinationStreetName = [destinationStreetName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSString *destinationCity = destinationPlacemark.locality;
            destinationCity = [destinationCity stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSString *destinationState = sourcePlacemark.administrativeArea;
            destinationState = [destinationState stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            
            NSString *directionsString = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@+%@,+%@,+%@&daddr=%@+%@,+%@,+%@", sourceStreetNumber, sourceStreetName, sourceCity, sourceState, destinationStreetNumber, destinationStreetName, destinationCity, destinationState];
            NSURL *url = [NSURL URLWithString:directionsString];
            [[UIApplication sharedApplication] openURL:url];
            
            self.hasProvidedDirections = YES;
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
    }
        [self.locationManager startUpdatingLocation];
}

@end
