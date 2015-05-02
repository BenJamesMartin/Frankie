//
//  FrankieDetailProjectViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/14/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieDetailProjectViewController.h"
#import "FrankieAddEditContractViewController.h"
#import "FrankieAppDelegate.h"
#import "RTNActivityView.h"
#import "ProjectStep.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import <UITextField+Shake/UITextField+Shake.h>

@implementation FrankieDetailProjectViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UIBarButtonItem *editProjectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProject)];
    self.navigationItem.rightBarButtonItem = editProjectButton;
    
    self.navigationItem.title = self.job.title;
    [self drawSegmentedControl];
    self.locationView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 312)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 312) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FrankieDetailProjectStepsTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.interchangeableView addSubview:self.tableView];
    
    [self loadProjectData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadProjectData];
    self.hasFinishedLoading = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIView setAnimationsEnabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Save any changes in steps
    NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Job class])];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF = %@", self.job.objectID];
    request.fetchLimit = 1;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    Job *job = fetchedObjects[0];
    [job setValue:self.job.steps forKey:@"steps"];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
            });
        }
    });
}


#pragma mark - Top-right button for editing project

- (void)editProject
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FrankieAddEditContractViewController *aevc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieAddEditContractViewController"];
    aevc.job = self.job;
    [self.navigationController pushViewController:aevc animated:YES];
}


#pragma mark - Load (or reload) project data

- (void)loadProjectData
{
    // Load (or reload) project title, client information,
    self.navigationItem.title = self.job.title;
    
    NSDictionary *clientInformation = self.job.clientInformation;
    NSString *name = clientInformation[@"name"];
    if (name != nil && name.length > 0)
        self.clientName.text = name;
    else
        self.clientName.text = @"[Client Name]";
    
    self.dateRange.text = [self setDateRangeText];
    
    UIImage *image = [UIImage imageWithData:self.job.picture];
    if (image != nil && ![image isEqual:[UIImage imageNamed:@"image-upload-icon"]]) {
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.layer.borderWidth = 0.0;
        self.image.image = image;
    }
    else {
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.image = [UIImage imageNamed:@"image-upload-icon-small"];
        self.image.layer.borderColor = [UIColor colorWithRed:200/255.f green:200/255.f blue:200/255.f alpha:1.0].CGColor;
        self.image.layer.borderWidth = 2.0;
    }
    
    if (self.job.notes != nil && ![self.job.notes isEqualToString:@""]) {
        self.notes.textAlignment = NSTextAlignmentLeft;
        self.notes.text = self.job.notes;
    }
    else {
        self.notes.textAlignment = NSTextAlignmentCenter;
        self.notes.text = @"No project notes.";
    }
    
    [self.tableView reloadData];
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
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Steps", @"Location"]];
    
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor],
              NSFontAttributeName: [UIFont fontWithName:@"Avenir" size:14.0]}];
        return attString;
    }];
    
    // ** --- Font : Segmented Control Profile --- **
    UIColor *lightGrayHeader = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    self.segmentedControl.frame = CGRectMake(0, 228, self.view.frame.size.width, 40);
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.segmentedControl.selectionIndicatorHeight = 2.0f;
    self.segmentedControl.selectionIndicatorColor = [UIColor lightGrayColor];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.backgroundColor = lightGrayHeader;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.view addSubview:self.segmentedControl];
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


#pragma mark - Contact client actions

- (IBAction)callClient:(id)sender
{
    NSDictionary *clientInformation = self.job.clientInformation;
    NSString *phoneNumber = clientInformation[@"phone"];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (phoneNumber != nil && phoneNumber.length > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]]];
    else {
        [self presentModalVCWithInfo:@{ @"type" : @"phone", @"message" : @"Enter a phone number for this client:"}];
    }
}

- (IBAction)emailClient:(id)sender
{
    NSDictionary *clientInformation = self.job.clientInformation;
    NSString *email = clientInformation[@"email"];
    if (email != nil && email.length > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", email]]];
    else {
        [self presentModalVCWithInfo:@{ @"type" : @"email", @"message" : @"Enter an email for this client:"}];
    }
}

- (IBAction)textClient:(id)sender
{
    NSDictionary *clientInformation = self.job.clientInformation;
    NSString *phoneNumber = clientInformation[@"phone"];
    if (phoneNumber != nil && phoneNumber.length > 0)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:+%@", phoneNumber]]];
    else
        [self presentModalVCWithInfo:@{ @"type" : @"text", @"message" : @"Enter a phone number for this client:"}];
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
    if (steps.count == 0 && self.segmentedControl.selectedSegmentIndex == 0)
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
    cell.step = step;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
        [self formatDateLabelAsDaysSinceForCell:cell];
    }
    
    if (step.picture != nil && ![step.picture isEqual:[UIImage imageNamed:@"image-upload-icon"]])
        cell.picture.image = step.picture;
    else
        cell.picture.image = [UIImage imageNamed:@"image-upload-icon-small"];
    
    cell.name.text = step.name;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(moveCell:)];
    longPress.minimumPressDuration = 0.01;
    [cell addGestureRecognizer:longPress];
    
    return cell;
}


#pragma mark - Format dueIn label in cell

- (void)formatDateLabelAsDaysSinceForCell:(FrankieProjectDetailStepsTableViewCell *)cell
{
    ProjectStep *step = cell.step;
    double timeSinceDueDateInSeconds = [step.dueDate timeIntervalSinceNow];
    int numberOfDays;
    if (timeSinceDueDateInSeconds / 86400 >= 0) {
        numberOfDays = floor(timeSinceDueDateInSeconds / 86400);
    }
    else {
        numberOfDays = ceil(timeSinceDueDateInSeconds / 86400);
    }
    
    if (numberOfDays > 0) {
        if (numberOfDays == 1) {
            cell.dueIn.text = @"DUE TOMORROW";
            if (!self.hasFinishedLoading)
                cell.lateStepIcon.alpha = 1.0;
        }
        else
            cell.dueIn.text = [NSString stringWithFormat:@"Due in %d days", numberOfDays];
    }
    else if (numberOfDays == 0) {
        cell.dueIn.text = @"DUE TODAY";
        if (!self.hasFinishedLoading)
            cell.lateStepIcon.alpha = 1.0;
    }
    else {
        numberOfDays = abs(numberOfDays);
        cell.lateStepIcon.alpha = 1.0;
        if (!self.hasFinishedLoading)
        if (numberOfDays == 1)
            cell.dueIn.text = @"DUE YESTERDAY";
        else
            cell.dueIn.text = [NSString stringWithFormat:@"DUE %d DAYS AGO", numberOfDays];
    }
}


#pragma mark - Long press gesture recognizer to complete project step

- (void)moveCell:(UILongPressGestureRecognizer *)gesture
{
    __block FrankieProjectDetailStepsTableViewCell *cell = (FrankieProjectDetailStepsTableViewCell *)gesture.view;
    [cell pop_removeAllAnimations];
    self.cellToAnimate = cell;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.gestureHasEnded = NO;
        
        POPDecayAnimation *anim = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPositionX];
        anim.delegate = self;
        anim.velocity = @(500.);
        anim.name = @"decayAnimation";
        [cell.layer pop_addAnimation:anim forKey:@"decayAnimation"];
        
        POPBasicAnimation *fadeAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadeAnim.delegate = self;
        fadeAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        fadeAnim.fromValue = @(1.0);
        fadeAnim.toValue = @(0.1);
        fadeAnim.duration = 1.2;
        fadeAnim.name = @"fadeAnimation";
        [cell.contentView pop_addAnimation:fadeAnim forKey:@"fadeAnimation"];
    }
    
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        // If the gesture has ended, the animation should end as well, reverting the cell back to its base state
        self.gestureHasEnded = YES;
        
        // Toggle cell completion state
        NSArray *steps = self.job.steps;
        int index = (int)[steps indexOfObject:cell.step];
        ProjectStep *step = steps[index];
        
        step.completed = !step.completed;
        step.completionDate = (step.completionDate ? step.completionDate : [NSDate date]);
    }
}


#pragma mark - Pop animation delegate

// When the cell is moving back to its base state, toggle the completion checkmark image of the step cell
- (void)pop_animationDidStart:(POPAnimation *)anim
{
    float animationDuration = 0.2;
//    __block BOOL shouldAnimateBackLateStep = NO;
    
    if ([anim.name isEqualToString:@"layerPositionAnimation"]) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.cellToAnimate.checkmarkImage.alpha = 0.0;
            self.cellToAnimate.dueIn.alpha = 0.0;
            self.cellToAnimate.lateStepIcon.alpha = 0.0;
        } completion:^(BOOL finished) {
            if ([self.cellToAnimate.checkmarkImage.image isEqual:[UIImage imageNamed:@"checkmark-empty"]]) {
                self.cellToAnimate.checkmarkImage.image = [UIImage imageNamed:@"checkmark-filled"];
                ProjectStep *step = self.cellToAnimate.step;
                NSDateFormatter *formatter = [NSDateFormatter new];
                formatter.dateFormat = @"MMMM dd, yyyy";
                NSString *formattedDate = [formatter stringFromDate:step.completionDate];
                self.cellToAnimate.dueIn.text = [NSString stringWithFormat:@"Completed %@", formattedDate];
                [UIView animateWithDuration:(animationDuration * 2) animations:^{
                    self.cellToAnimate.checkmarkImage.alpha = 1.0;
                    self.cellToAnimate.dueIn.alpha = 1.0;
                }];
            }
            else {
                self.cellToAnimate.checkmarkImage.image = [UIImage imageNamed:@"checkmark-empty"];
                [self formatDateLabelAsDaysSinceForCell:self.cellToAnimate];
                NSDate *dueDate = self.cellToAnimate.step.dueDate;
                if (fabs([dueDate timeIntervalSinceNow]) < 172799) {
                    [UIView animateWithDuration:(animationDuration * 2) animations:^{
                        self.cellToAnimate.lateStepIcon.alpha = 1.0;
                        self.cellToAnimate.checkmarkImage.alpha = 1.0;
                        self.cellToAnimate.dueIn.alpha = 1.0;
                    }];
                }
                else {
                    [UIView animateWithDuration:(animationDuration * 2) animations:^{
                        self.cellToAnimate.checkmarkImage.alpha = 1.0;
                        self.cellToAnimate.dueIn.alpha = 1.0;
                    }];
                }
            }
        }];
    }
}

- (void)pop_animationDidApply:(POPDecayAnimation *)anim
{
    if (self.gestureHasEnded && [anim.name isEqualToString:@"decayAnimation"]) {
        [self addDecayAnimationWithAnimation:anim];
        [self addAlphaAnimationWithAnimation];
    }
}

- (void)pop_animationDidStop:(POPDecayAnimation *)anim finished:(BOOL)finished
{
    if (!self.gestureHasEnded && [anim.name isEqualToString:@"decayAnimation"]) {
        [self addDecayAnimationWithAnimation:anim];
        [self addAlphaAnimationWithAnimation];
    }
}


#pragma mark - Pop animation convenience methods

- (void)addDecayAnimationWithAnimation:(POPDecayAnimation *)anim
{
    [self.cellToAnimate.layer pop_removeAnimationForKey:@"decayAnimation"];
    CGPoint currentVelocity = [anim.velocity CGPointValue];
    CGPoint velocity = CGPointMake(currentVelocity.x, -currentVelocity.y);
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionAnimation.name = @"layerPositionAnimation";
    positionAnimation.delegate = self;
    positionAnimation.velocity = [NSValue valueWithCGPoint:velocity];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self.cellToAnimate];
    positionAnimation.toValue = [NSValue valueWithCGPoint: CGPointMake(self.cellToAnimate.contentView.center.x, self.cellToAnimate.contentView.center.y * (((indexPath.row + 1) * 2) - 1))];
    positionAnimation.springBounciness = 10.0;
    [self.cellToAnimate.layer pop_addAnimation:positionAnimation forKey:@"layerPositionAnimation"];
}

- (void)addAlphaAnimationWithAnimation
{
    // Fade back fade animation
    [self.cellToAnimate.contentView pop_removeAnimationForKey:@"fadeAnimation"];
    POPBasicAnimation *fadeAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    fadeAnim.fromValue = @(self.cellToAnimate.contentView.alpha);
    fadeAnim.toValue = @(1.0);
    fadeAnim.duration = 0.4;
    fadeAnim.name = @"fadeAnimation";
    [self.cellToAnimate.contentView pop_addAnimation:fadeAnim forKey:@"fadeAnimation"];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
        [self.locationManager startUpdatingLocation];   
    }
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingAnimator new];
}


#pragma mark - Present modal VC for entering phone/email

- (void)presentModalVCWithInfo:(NSDictionary *)info
{
    self.contactInfoType = info[@"type"];
    NSString *message = info[@"message"];
    
    self.modalVC = [ModalViewController new];
    self.modalVC.transitioningDelegate = self;
    self.modalVC.modalPresentationStyle = UIModalPresentationCustom;
    
    CGFloat labelWidth = 140.0;
    CGFloat widthTextField = 140.0;
    CGFloat heightTextField = 40.0;
    CGFloat yOffsetTextField = 90.0;
    CGFloat yOffsetSubmitButton = 140.0;
    CGFloat yOffsetTop = -10.0;
    CGFloat modalWidth = 220.0;
    
    [self addDoneButton];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(modalWidth / 2 - labelWidth / 2, yOffsetTop, labelWidth, 100)];
    messageLabel.font = [UIFont fontWithName:@"Avenir" size:14.0];
    messageLabel.textColor = [UIColor darkGrayColor];
    messageLabel.text = message;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 5;
    [self.modalVC.view addSubview:messageLabel];
    
    self.modalField = [[FUITextField alloc] initWithFrame:CGRectMake(modalWidth / 2 - widthTextField / 2, yOffsetTextField, widthTextField, heightTextField)];
    if ([self.contactInfoType isEqualToString:@"phone"] || [self.contactInfoType isEqualToString:@"text"])
        self.modalField.placeholder = @"Enter phone number";
    else
        self.modalField.placeholder = @"Enter email";
    self.modalField.font = [UIFont fontWithName:@"Avenir" size:14.0];
    self.modalField.backgroundColor = [UIColor clearColor];
    self.modalField.edgeInsets = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    self.modalField.textFieldColor = [UIColor whiteColor];
    self.modalField.textColor = [UIColor grayColor];
    self.modalField.borderColor = [UIColor lightGrayColor];
    self.modalField.borderWidth = 2.0f;
    self.modalField.cornerRadius = 3.0f;
    self.modalField.textAlignment = NSTextAlignmentCenter;
    self.modalField.delegate = self;
    
    if ([self.contactInfoType isEqualToString:@"phone"] || [self.contactInfoType isEqualToString:@"text"])
        self.modalField.keyboardType = UIKeyboardTypeNamePhonePad;
    else
        self.modalField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.modalField becomeFirstResponder];
    [self.modalVC.view addSubview:self.modalField];
    
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(modalWidth / 2 - widthTextField / 2, yOffsetSubmitButton, widthTextField, heightTextField)];
    NSString *buttonTitle = @"";
    if ([self.contactInfoType isEqualToString:@"text"])
        buttonTitle = @"Text Client";
    else if ([self.contactInfoType isEqualToString:@"phone"])
        buttonTitle = @"Call Client";
    else
        buttonTitle = @"Email Client";
    [submitButton setTitle:buttonTitle forState:UIControlStateNormal];
    submitButton.layer.cornerRadius = 3.0;
    submitButton.backgroundColor = [UIColor colorWithRed:1.0 green:107/255.f blue:57/255.f alpha:1.0];
    submitButton.font = [UIFont fontWithName:@"Avenir" size:16.0];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(saveClientInformation) forControlEvents:UIControlEventTouchUpInside];
    [self.modalVC.view addSubview:submitButton];
    
    [self.navigationController presentViewController:self.modalVC
                                            animated:YES
                                          completion:NULL];
}


#pragma mark - Format phone number

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.textColor = [UIColor grayColor];
    
    if ([self.contactInfoType isEqualToString:@"email"])
        return YES;
    
    int length = [self getLength:textField.text];
    
    if (length == 10)
    {
        NSLog(@"length is 10");
        if (range.length == 0) {
            NSLog(@"not changing");
            return NO;
        }
    }
    
    if (length == 3) {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"%@-",num];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@-",[num substringToIndex:3]];
    }
    else if (length == 6) {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"%@-%@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@-%@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
}

- (NSString*)formatNumber:(NSString*)mobileNumber
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


- (int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
}


#pragma mark - Add done button to modal VC

- (void)addDoneButton
{
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    dismissButton.tintColor = [UIColor colorWithRed:52/255.f green:152/255.f blue:219/255.f alpha:1.0];
    dismissButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:18.0];
    [dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismissModalVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.modalVC.view addSubview:dismissButton];
    
    [self.modalVC.view addConstraint:[NSLayoutConstraint constraintWithItem:dismissButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.modalVC.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f
                                                           constant:0.f]];
    
    [self.modalVC.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[dismissButton]-10-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(dismissButton)]];
}


#pragma mark - Button events in modal VC

- (void)saveClientInformation
{
    if ([self.contactInfoType isEqualToString:@"email"]) {
        if (![self NSStringIsValidEmail:self.modalField.text]) {
            [self.modalField shake:5 withDelta:8.0 speed:0.03 completion:nil];
            self.modalField.textColor = [UIColor alizarinColor];
            return;
        }
    }
    else if ([self.contactInfoType isEqualToString:@"phone"] || [self.contactInfoType isEqualToString:@"text"]) {
        if (self.modalField.text.length < 12) {
            [self.modalField shake:5 withDelta:8.0 speed:0.03 completion:nil];
            self.modalField.textColor = [UIColor alizarinColor];
            return;
        }
    }
    
    // Get a copy of relevant Core Data project
    NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Job class])];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF = %@", self.job.objectID];
    request.fetchLimit = 1;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:nil];
    Job *job = fetchedObjects[0];
    
    // Set the contact information for the project
    NSString *type = self.contactInfoType;
    NSMutableDictionary *clientInformation = job.clientInformation;
    if (clientInformation == nil)
        clientInformation = @{ self.contactInfoType : self.modalField.text }.mutableCopy;
    else
        clientInformation[self.contactInfoType] = self.modalField.text;
    
    [job setValue:clientInformation forKey:@"clientInformation"];
    
    // Save the Core Data context
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
        }
    });
    
    // Perform correct action here of calling/texting/emailing
    if ([self.contactInfoType isEqualToString:@"email"])
        [self emailClient:nil];
    else if ([self.contactInfoType isEqualToString:@"phone"])
        [self callClient:nil];
    else
        [self textClient:nil];
    
    [self dismissModalVC:nil];
}

- (void)dismissModalVC:(id)sender
{
    [self.modalVC dismissViewControllerAnimated:YES completion:nil];
}
        
        
#pragma mark - Email validation
        
- (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}



@end
