//
//  FrankieDetailProjectViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/14/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <HMSegmentedControl/HMSegmentedControl.h>
#import <pop/POP.h>
#import <FlatUIKit/FlatUIKit.h>
#import "ModalViewController.h"
#import "Project.h"
#import "FrankieProjectDetailStepsTableViewCell.h"

@interface FrankieDetailProjectViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, POPAnimationDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) Project *project;

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *clientName;
@property (strong, nonatomic) IBOutlet UILabel *dateRange;
@property (strong, nonatomic) IBOutlet UITextView *notes;

@property (strong, nonatomic) HMSegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *interchangeableView;
@property (strong, nonatomic) IBOutlet UILabel *noStepsLabel;
@property (strong, nonatomic) IBOutlet UIButton *createFirstStepButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MKMapView *locationView;

@property (assign, nonatomic) BOOL gestureHasEnded;
@property (strong, nonatomic) FrankieProjectDetailStepsTableViewCell *cellToAnimate;

// Map pin
@property (strong, nonatomic) MKPointAnnotation *annotation;
@property (strong, nonatomic) IBOutlet UIButton *directionsButton;

// Because directions are provided from the didUpdateLocations callback, which is called multiple times per minute, ensure directions are only obtained once.
@property (assign, nonatomic) BOOL hasProvidedDirections;

@property (assign, nonatomic) BOOL hasFinishedLoading;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) ModalViewController *modalVC;
@property (strong, nonatomic) FUITextField *modalField;
@property (strong, nonatomic) NSString *contactInfoType;


@end
