//
//  FrankieMasterContractViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 1/8/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

#import "FrankieMasterContractViewController.h"
#import "FrankieDetailContractViewController.h"
#import "FrankieAddContractViewController.h"
#import "FrankieLoginViewController.h"
#import "FrankieAppDelegate.h"
#import "Job.h"

@interface FrankieMasterContractViewController ()

@end

@implementation FrankieMasterContractViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIImageView *image = [UIImageView new];
    self.defaultImage.frame = CGRectMake(10, 12, 60, 60);
    self.defaultImage.backgroundColor = [UIColor colorWithRed:(240/255.f) green:(240/255.f) blue:(240/255.f) alpha:1.0];
    
    CALayer *layer = [self.defaultImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:30.0];
    
//    [self deleteDataFromModel];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    
    //102, 204, 255
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(102/255.f) green:(204/255.f) blue:(255/255.f) alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // \u2630 hamburger unicode
    // Get custom hamburger icon and use left-menu popover
    // For now just have simple "logout" button
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logOutUser)];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
      target:self
      action:@selector(loadAddContractViewController)];
    
    self.tableData = [NSMutableArray new];
    self.tableData = [self loadDataFromModel:nil];
    NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"dueDate"
                                                                 ascending:NO];
    
    self.tableData = [self.tableData sortedArrayUsingDescriptors:@[sortByDate]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadTable" object:nil];
    
    self.navigationController.navigationBar.alpha = 0.96;
}

- (void)loadAddContractViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FrankieAddContractViewController *addContractVC = [storyboard instantiateViewControllerWithIdentifier:@"AddContract"];
    [self.navigationController pushViewController:addContractVC animated:YES];
}

- (void)logOutUser {
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)reloadTable {
    self.tableData = [self loadDataFromModel:nil];
    NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"dueDate"
                                                                 ascending:NO];
    self.tableData = [self.tableData sortedArrayUsingDescriptors:@[sortByDate]];
    
//    NSLog(@"tableData: %@", self.tableData);
    [self.tableView reloadData];
}

-(NSArray *) loadDataFromModel:(NSString *)searchFor
{
    NSError *error;
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:NSStringFromClass([Job class])
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    if (fetchedObjects == nil)
        NSLog(@"Error: %@", error);
    
    NSMutableArray *tableData = [NSMutableArray new];
    
    for (Job *entity in fetchedObjects)
    {
        NSArray *keys = [[[entity entity] attributesByName] allKeys];
        NSDictionary *dict = [entity dictionaryWithValuesForKeys:keys];
        [tableData addObject:dict];
    }
    
    if (searchFor == nil)
    {
        return tableData;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@",searchFor];
    return [[NSArray alloc] initWithObjects:[tableData filteredArrayUsingPredicate:predicate], nil];
}

- (void)deleteDataFromModel {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entityDesc =
    [NSEntityDescription entityForName:NSStringFromClass([Job class])
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Job class])];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:req error:&error];
    if (fetchedObjects == nil)
        NSLog(@"Error: %@", error);
    
    for (Job *job in fetchedObjects) {
        [context deleteObject:job];
    }
    [context save:&error];
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)
//        return @"Last Week";
//    else
//        return @"Before that";
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableViefw commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        PFQuery *postQuery = [PFQuery queryWithClassName:@"Project"];
        [postQuery whereKey:@"objectId" equalTo:[self.tableData objectAtIndex:indexPath.row][@"parseId"]];
        [postQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                [object deleteEventually];
            }
            else {
                NSLog(@"parse row delete error: %@", error);
            }
        }];
        
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Job class])];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", [self.tableData objectAtIndex:indexPath.row][@"objectId"]];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
        if (fetchedObjects == nil)
            NSLog(@"Error: %@", error);
        
        for (Job *job in fetchedObjects) {
            [context deleteObject:job];
        }
        [context save:&error];
        
        // Goes inside background thread block where thing is being deleted
        [self reloadTable];
    }
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
////    return 2;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 20, 35)];
//    headerLabel.text = @"    Test";
//    headerLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
//    headerLabel.backgroundColor = [UIColor colorWithRed:(128/255.f) green:(176/255.f) blue:(211/255.f) alpha:1.0];
//    headerLabel.textColor = [UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1.0];
//    
//    
//    // I have heard that UINavigationController has parralax automatticly applied to it, so you could hack a solution from that.
//    // http://stackoverflow.com/questions/18972994/ios-7-parallax-effect-in-my-view-controller
//    
//    UINavigationController *test = [UINavigationController new];
//    test.navigationBar.frame = CGRectMake(0, 0, 0, 0);
//    
//    return headerLabel;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    
//    return 30.0;
//    
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - cellForRow

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    UIImageView *image = [UIImageView new];
    image.frame = CGRectMake(10, 12, 60, 60);
    
    
    if ([[self.tableData objectAtIndex:indexPath.row][@"picture"] isEqual:[NSNull null]]) {
        image.image = [UIImage imageNamed:@"image-upload-icon-small"];
    }
    else {
        CALayer *layer = [image layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:30.0];
        image.image = [UIImage imageWithData:[self.tableData objectAtIndex:indexPath.row][@"picture"]];
        image.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    
//    CALayer *border = image.layer;
//    border.borderColor = [[UIColor blackColor] CGColor];
//    border.borderWidth = 1;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 200, 30)];
    
    if ([[self.tableData objectAtIndex:indexPath.row][@"title"] isEqualToString:@""]) {
        title.text = @"[No Title]";
    }
    else {
        title.text = [self.tableData objectAtIndex:indexPath.row][@"title"];
    }
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    title.textColor = [UIColor grayColor];
//    CALayer *labelBorder = title.layer;
//    labelBorder.borderColor = [[UIColor blackColor] CGColor];
//    labelBorder.borderWidth = 1;
    
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, 200, 30)];
    if ([[self.tableData objectAtIndex:indexPath.row][@"price"] floatValue] == 0) {
        price.text = @"Price: [Not Set]";
    }
    else {
        NSNumber *number = (NSNumber*)[self.tableData objectAtIndex:indexPath.row][@"price"];
        [price setText:[NSString stringWithFormat:@"Price: $%.02f", number.floatValue]];
    }
    price.font = [UIFont fontWithName:@"Helvetica" size:12];
    price.textColor = [UIColor grayColor];
    
    UILabel *dueDate = [[UILabel alloc] initWithFrame:CGRectMake(80, 45, 200, 30)];
//    NSDateFormatter *dateToString = [[NSDateFormatter alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy"];
    
    if ([self.tableData objectAtIndex:indexPath.row][@"dueDate"] == nil || [self.tableData objectAtIndex:indexPath.row][@"dueDate"] == [NSNull null]) {
        dueDate.text = @"Due Date: [Not Set]";
    }
    else {
        dueDate.text = [NSString stringWithFormat:@"Due Date: %@",[NSString stringWithFormat:@"%@", [format stringFromDate:[self.tableData objectAtIndex:indexPath.row][@"dueDate"]]]];
    }
    
    dueDate.font = [UIFont fontWithName:@"Helvetica" size:12];
    dueDate.textColor = [UIColor grayColor];
    
    [cell addSubview:title];
    [cell addSubview:image];
//    [cell addSubview:self.defaultImage];
    [cell addSubview:price];
    [cell addSubview:dueDate];
    
    UIButton *myAccessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 14)];
    // 183, 79, 48
//    [myAccessoryButton setBackgroundColor:[UIColor colorWithRed:(183/255.f) green:(79/255.f) blue:(48/255.f) alpha:1.0]];
    [myAccessoryButton setImage:[UIImage imageNamed:@"custom-detail-disclosure.png"] forState:UIControlStateNormal];
    [cell setAccessoryView:myAccessoryButton];
    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

//    cell.textLabel.text = [NSString stringWithFormat:@"This row is %d", indexPath.row+1];
//    
//    cell.detailTextLabel.text = @"hi";
//    
//    cell.imageView.image = [UIImage imageNamed:@"camera-upload.png"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Push view controller instead of performing segue
 
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FrankieDetailContractViewController *detailContractVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailContract"];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    detailContractVC.project = @{
                     @"title" : [self.tableData objectAtIndex:path.row][@"title"],
                     @"nextStep":  [self.tableData objectAtIndex:path.row][@"nextStep"],
                     @"dueDate": [self.tableData objectAtIndex:path.row][@"dueDate"],
                     @"notes": [self.tableData objectAtIndex:path.row][@"notes"],
                     @"completed": [self.tableData objectAtIndex:path.row][@"completed"],
                     @"picture": [self.tableData objectAtIndex:path.row][@"picture"],
                     @"price": [self.tableData objectAtIndex:path.row][@"price"],
                     @"objectId": [self.tableData objectAtIndex:path.row][@"objectId"],
                     @"parseId" : [self.tableData objectAtIndex:path.row][@"parseId"]
                     };
    [self.navigationController pushViewController:detailContractVC animated:YES];
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString: @"showDetail"]) {
//        FrankieDetailContractViewController * SCVC = [segue destinationViewController];
//        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
//        SCVC.project = @{
//                         @"title" : [self.tableData objectAtIndex:path.row][@"title"],
//                         @"nextStep":  [self.tableData objectAtIndex:path.row][@"nextStep"],
//                         @"dueDate": [self.tableData objectAtIndex:path.row][@"dueDate"]
//                         };
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - UIImagePickerController delegate methods

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    
}

@end
