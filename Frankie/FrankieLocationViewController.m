//
//  FrankieLocationViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/5/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieLocationViewController.h"
#import "FrankieAddContractViewController.h"

@interface FrankieLocationViewController ()

@end

@implementation FrankieLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    
    [searchBar setTintColor:[UIColor whiteColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor colorFromHexCode:@"007AFF"]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:14.0]}];
    
    
//    NSString *addressString = @"http://maps.apple.com/?q=1+Infinite+Loop,+Cupertino,+CA";
//    NSURL *url = [NSURL URLWithString:addressString];
//    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    FrankieAddContractViewController *avc = [self.navigationController.viewControllers lastObject];
    avc.locationPlacemark = self.placemark;
    
    // Modify table view cell in add contract VC associated with location VC
    NSIndexPath *tableSelection = [avc.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [avc.tableView cellForRowAtIndexPath:tableSelection];
    
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"%@ %@   ", self.placemark.subThoroughfare, self.placemark.thoroughfare];
    label.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
    label.textColor = [UIColor darkGrayColor];
    [label sizeToFit];
    cell.accessoryView = label;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    CLGeocoder *geocoder = [CLGeocoder new];
//    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
//        
//    }];
    
    [SVGeocoder geocode:searchBar.text
        completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
            SVPlacemark *placemark = [placemarks firstObject];
            CLLocationCoordinate2D coordinate = placemark.coordinate;
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:coordinate];
            [annotation setTitle:searchBar.text];
            [self.mapView addAnnotation:annotation];
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
            [self.mapView setRegion:region animated:YES];
            
            self.placemark = placemark;
            
            [searchBar resignFirstResponder];
        }];
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
