//
//  FrankieMasterContractViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 1/8/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

#import "FrankieMasterContractViewController.h"
#import "FrankieDetailContractViewController.h"
#import "FrankieAddContractViewController.h"
#import "FrankieLoginViewController.h"
#import "FrankieAppDelegate.h"
#import "Job.h"
#import "SIAlertView.h"

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

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self syncParseCoreData];
    
    self.fetchedResultsController.delegate = self;
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"fetchedResults error %@, %@", error, [error userInfo]);
	}

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadTable" object:nil];
    
    self.navigationController.navigationBar.alpha = 0.96;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    // Because both the property name and the method name are 'fetchedResultsController', we must use _fetchedResultsController to access the property. self.fetchedResultsController will call the method, resulting in an infinite loop. The exception is when setting the property as we do below, e.g. self.fetchedResultsController = [something] or when sending a message to that instance as we do below with [fetchedResultsController performFetch:].
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *context =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:NSStringFromClass([Job class])
                inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                                   ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context
                                          sectionNameKeyPath:@"title"
                                                   cacheName:nil];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

#pragma mark - NSFetchedResultsController delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(UITableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Have call here to reloadData?    http://stackoverflow.com/questions/3077332/how-to-refresh-a-uitableviewcontroller-or-nsfetchedresultscontroller
    [self.tableView endUpdates];
}

#pragma mark - miscellaneous

// Test method for syncing Parse with Core Data.
- (void)addParseObject {
    PFObject *project = [PFObject objectWithClassName:@"Project"];
    project[@"user"] = [PFUser currentUser];
    project[@"title"] = @"hi";

    project[@"start"] = [NSDate date];
    project[@"end"] = [NSDate date];
    
    UIImage *image = [UIImage imageNamed:@"random.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);
    project[@"picture"] = [PFFile fileWithData:imageData];
    
    project[@"completed"] = [NSNumber numberWithBool:NO];
    project[@"price"] = [NSNumber numberWithFloat:44.3];
    project[@"notes"] = @"notes";
    project.ACL = [PFACL ACLWithUser:[PFUser currentUser]];

    [project saveInBackground];
}

- (void)syncParseCoreData {
    NSError *error;
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:NSStringFromClass([Job class])
                                                  inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Project"];
    [postQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *projectsToAdd = [NSMutableArray new];
            NSMutableArray *projectsToDelete = [NSMutableArray new];
            BOOL found = NO;
            
            for (PFObject *project in objects) {
                for (Job *job in fetchedObjects)
                {
                    if ([job.parseId isEqualToString:[project objectId]]) {
                        found = YES;
                        break;
                    }
                }
                if (found == NO) {
                    [projectsToAdd addObject:project];
                }
                found = NO;
            }
            for (Job *job in fetchedObjects)
            {
                for (PFObject *project in objects) {
                    if ([job.parseId isEqualToString:[project objectId]]) {
                        found = YES;
                        break;
                    }
                }
                if (found == NO) {
                    [projectsToDelete addObject:job];
                }
                found = NO;
            }
            for (PFObject *project in projectsToAdd) {
                NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Job class]) inManagedObjectContext:context];
                
                [entity setValue:project[@"title"] forKeyPath:@"title"];
                [entity setValue:project[@"end"] forKeyPath:@"dueDate"];
                [entity setValue:project[@"price"] forKeyPath:@"price"];
                [entity setValue:project[@"notes"] forKeyPath:@"notes"];
                [entity setValue:UIImagePNGRepresentation(project[@"photo"]) forKeyPath:@"picture"];
                [entity setValue:[project objectId] forKeyPath:@"parseId"];
                [entity setValue:[[[(NSManagedObject*)entity objectID] URIRepresentation] absoluteString] forKeyPath:@"objectId"];
                [entity setValue:project[@"completed"] forKeyPath:@"completed"];
            }
            for (Job *job in projectsToDelete) {
                [context deleteObject:job];
            }
            if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
            }
        }
        else {
            NSLog(@"Parse find all objects error: %@", error);
        }
    }];
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
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"fetchedResults error %@, %@", error, [error userInfo]);
	}
    
    [self.tableView reloadData];
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

#pragma mark - UITableViewDelegate methods

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Job *job = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        PFQuery *postQuery = [PFQuery queryWithClassName:@"Project"];
        [postQuery whereKey:@"objectId" equalTo:job.parseId];
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", job.objectId];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
        if (fetchedObjects == nil)
            NSLog(@"Error: %@", error);
        
        for (Job *job in fetchedObjects) {
            [context deleteObject:job];
        }
        [context save:&error];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}



//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 20, 35)];
//    headerLabel.text = @"    Test";
//    headerLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
//    headerLabel.backgroundColor = [UIColor colorWithRed:(128/255.f) green:(176/255.f) blue:(211/255.f) alpha:1.0];
//    headerLabel.textColor = [UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1.0];
//    
//    
//    // I have heard that UINavigationController has parralax automatically applied to it, so you could hack a solution from that.
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - cellForRow

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Job *job = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    UIImageView *image = [UIImageView new];
    image.frame = CGRectMake(10, 12, 60, 60);
    if ([job.picture isEqual:[NSNull null]] || job.picture == NULL) {
        image.image = [UIImage imageNamed:@"image-upload-icon-small"];
    }
    else {
        CALayer *layer = [image layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:30.0];
        image.image = [UIImage imageWithData:job.picture];
        image.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 200, 30)];
    
    if ([job.title isEqualToString:@""]) {
        title.text = @"[No Title]";
    }
    else {
        title.text = job.title;
    }
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    title.textColor = [UIColor grayColor];
    
    UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, 200, 30)];
    if ([job.price floatValue] == 0) {
        price.text = @"Price: [Not Set]";
    }
    else {
        NSNumber *number = (NSNumber*)job.price;
        [price setText:[NSString stringWithFormat:@"Price: $%.02f", number.floatValue]];
    }
    price.font = [UIFont fontWithName:@"Helvetica" size:12];
    price.textColor = [UIColor grayColor];
    
    UILabel *dueDate = [[UILabel alloc] initWithFrame:CGRectMake(80, 45, 200, 30)];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy"];
    
    if (job.dueDate == nil || job.dueDate == NULL) {
        dueDate.text = @"Due Date: [Not Set]";
    }
    else {
        dueDate.text = [NSString stringWithFormat:@"Due Date: %@",[NSString stringWithFormat:@"%@", [format stringFromDate:job.dueDate]]];
    }
    
    dueDate.font = [UIFont fontWithName:@"Helvetica" size:12];
    dueDate.textColor = [UIColor grayColor];
    
    if (job.completed == [NSNumber numberWithInt:1]) {
        UILabel *completed = [[UILabel alloc] initWithFrame:CGRectMake(80, 60, 200, 30)];
        completed.font = [UIFont fontWithName:@"Helvetica" size:12];
        completed.textColor = [UIColor colorWithRed:77/255.f green:189/255.f blue:51/255.f alpha:1.0];
        completed.text = @"Project Complete";
        [cell addSubview:completed];
    }
    
    [cell addSubview:title];
    [cell addSubview:image];
    [cell addSubview:price];
    [cell addSubview:dueDate];
    
    UIButton *myAccessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 14)];
    [myAccessoryButton setImage:[UIImage imageNamed:@"custom-detail-disclosure.png"] forState:UIControlStateNormal];
    [cell setAccessoryView:myAccessoryButton];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Push view controller instead of performing segue
 
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FrankieDetailContractViewController *detailContractVC = [storyboard instantiateViewControllerWithIdentifier:@"DetailContract"];
    
    Job *job = [_fetchedResultsController objectAtIndexPath:indexPath];
    NSEntityDescription *entity = [job entity];
    NSDictionary *attributes = [entity attributesByName];
    NSMutableDictionary *keysAndValues = [NSMutableDictionary new];
    
    // Changing nil to NSNull because app is crashing due to setting a nil value in the detailContractVC.project dictionary.
    for (NSString *attribute in attributes) {
        id value = [job valueForKey: attribute];
        if (value == nil) {
            [keysAndValues setValue:[NSNull null] forKey:attribute];
        }
        else {
            [keysAndValues setObject:value forKey:attribute];
        }
    }
    detailContractVC.project = keysAndValues;
    
   [self.navigationController pushViewController:detailContractVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 87;
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
