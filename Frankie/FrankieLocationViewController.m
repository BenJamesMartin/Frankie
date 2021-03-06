//
//  FrankieLocationViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/5/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieLocationViewController.h"
#import "FrankieAddEditContractViewController.h"
#import "FrankieProjectManager.h"
#import "RTNActivityView.h"

@interface FrankieLocationViewController ()

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation FrankieLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    
    [self.searchBar setTintColor:[UIColor whiteColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor colorFromHexCode:@"007AFF"]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:14.0]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Load existing data on viewDidAppear
- (void)viewDidAppear:(BOOL)animated
{
    self.placemark = [[FrankieProjectManager sharedManager] fetchLocation];
    if (self.placemark) {
        [self addAnnotationAtLocation:self.placemark];
        self.searchBar.text = [NSString stringWithFormat:@"%@ %@", self.placemark.subThoroughfare, self.placemark.thoroughfare];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    FrankieAddEditContractViewController *avc = [self.navigationController.viewControllers lastObject];
    avc.locationPlacemark = self.placemark;
    [[FrankieProjectManager sharedManager] saveLocation:self.placemark];
 
    if (self.placemark != nil) {
        // Modify table view cell in add contract VC associated with location VC
        NSIndexPath *tableSelection = [avc.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [avc.tableView cellForRowAtIndexPath:tableSelection];
        
        UILabel *label = [UILabel new];
        label.text = [NSString stringWithFormat:@"%@ %@   ", self.placemark.subThoroughfare, self.placemark.thoroughfare];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
        label.textColor = [UIColor darkGrayColor];
        [label sizeToFit];
        if (label.frame.size.width > 165) {
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, 165, label.frame.size.height);
        }
        cell.accessoryView = label;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [RTNActivityView show];
    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        [RTNActivityView hide];
        CLPlacemark *placemark = placemarks.lastObject;
        
        if (placemark == nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Location not found. Please use the city name for more accurate results." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:action];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            self.placemark = placemark;
            [self addAnnotationAtLocation:placemark];
            [searchBar resignFirstResponder];
        }
    }];
}

- (void)addAnnotationAtLocation:(CLPlacemark *)location
{
    MKPlacemark *mkPlacemark = [[MKPlacemark alloc] initWithPlacemark:location];
    [self.mapView addAnnotation:mkPlacemark];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mkPlacemark.coordinate, 1000, 1000);
    [self.mapView setRegion:region animated:YES];
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
