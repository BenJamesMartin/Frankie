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
#import "Job.h"

@interface FrankieDetailProjectViewController : UIViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) Job *job;
@property (assign, nonatomic) BOOL reloadDataOnReappear;

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *clientName;
@property (strong, nonatomic) IBOutlet UILabel *dateRange;
@property (strong, nonatomic) IBOutlet UITextView *notes;

@property (strong, nonatomic) IBOutlet UIView *interchangeableView;
@property (strong, nonatomic) IBOutlet UILabel *noStepsLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MKMapView *locationView;

// Map pin
@property (strong, nonatomic) MKPointAnnotation *annotation;
@property (strong, nonatomic) IBOutlet UIButton *directionsButton;

// Because directions are provided from the didUpdateLocations callback, which is called multiple times per minute, ensure directions are only obtained once.
@property (assign, nonatomic) BOOL hasProvidedDirections;

@property (strong, nonatomic) CLLocationManager *locationManager;

@end
