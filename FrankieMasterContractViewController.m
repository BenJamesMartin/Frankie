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
#import "FrankieMasterContractTableViewCell.h"
#import "FrankieDetailContractViewController.h"
#import "FrankieAddContractViewController.h"
#import "FrankieLoginViewController.h"
#import "FrankieSettingsViewController.h"
#import "FrankieAppDelegate.h"
#import "FrankieSideMenuViewController.h"
#import "Job.h"
#import "ProjectStep.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavigationBarAttributes];
    [self syncParseWithCoreData];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FrankieMasterContractTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    // Error handling when loading from fetched results controller
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadTable" object:nil];
}

- (void)setNavigationBarAttributes
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 0.96;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger-icon"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(revealLeftMenu)];
    self.fetchedResultsController.delegate = self;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
     target:self
     action:@selector(loadAddContractViewController)];
}

- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
//    NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
//    shadow.shadowOffset = CGSizeMake(0, 1);
//    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
//                                                           shadow, NSShadowAttributeName,
//                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
}

- (void)revealLeftMenu
{
    NSLog(@"done");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"revealSideMenu" object:nil];
//    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    FrankieSideMenuViewController *smvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieSideMenuViewController"];
//    [self.revealSideViewController pushViewController:smvc onDirection:PPRevealSideDirectionLeft animated:YES completion:^{
//        NSLog(@"completion");
//    }];
}

- (void)loadSettingsViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FrankieSettingsViewController *settingsVC = [storyboard instantiateViewControllerWithIdentifier:@"FrankieSettingsViewController"];
    [self.navigationController pushViewController:settingsVC animated:YES];
    NSLog(@"loadSettingsViewController");
}

- (NSFetchedResultsController *)fetchedResultsController
{
    // Because both the property name and the method name are 'fetchedResultsController', we must use _fetchedResultsController to access the property. self.fetchedResultsController will call the method, resulting in an infinite loop. The exception is when setting the property as we do below, e.g. self.fetchedResultsController = [something] or when sending a message to that instance as we do below with [fetchedResultsController performFetch:].
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *context =
    [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
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
	if (![self.fetchedResultsController performFetch:&error]) {
        // Error handling
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
            [self.tableView cellForRowAtIndexPath:indexPath];
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

- (void)syncParseWithCoreData {
    NSError *error;
    NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
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
            NSSet *currentProjects = [NSSet new];
            NSMutableArray *projectsToDelete = [NSMutableArray new];
            BOOL found = NO;
            
            for (PFObject *project in objects) {
                // Add project to set
            }
            for (Job *project in fetchedObjects) {
                // Add project to set
            }
            
            // User still can interact with app and store in Core Data when no connection
            // Use Core Data as the true data source
            // Add objects to Parse that exist in CD but not Parse
            // Delete objects from Parse that don't exist in CD but do in Parse.
            
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
                
                PFFile *imageFile = project[@"picture"];
                NSData *imageData = [imageFile getData];
                [entity setValue:imageData forKeyPath:@"picture"];
                
                [entity setValue:[project objectId] forKeyPath:@"parseId"];
                [entity setValue:[[[(NSManagedObject*)entity objectID] URIRepresentation] absoluteString] forKeyPath:@"objectId"];
                [entity setValue:project[@"completed"] forKeyPath:@"completed"];
            }
            for (Job *job in projectsToDelete) {
                [context deleteObject:job];
            }
            if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
            }
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
    [self.tableView reloadData];
}

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
        
        // Protect from trying to delete a parse object immediately after it was created.
        // This causes the program to crash with error "Can not do a comparison for query type: (null)"
        if ([job.parseId isEqual:[NSNull null]] || job.parseId == nil) {
            return;
        }
        
        PFQuery *postQuery = [PFQuery queryWithClassName:@"Project"];
        [postQuery whereKey:@"objectId" equalTo:job.parseId];
        [postQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error) {
                [object deleteEventually];
            }
        }];
        
        NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Job class])];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", job.objectId];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
        
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark - cellForRowAtIndexPath

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    FrankieMasterContractTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[FrankieMasterContractTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    return [self configureCell:cell atIndexPath:indexPath];
}

- (FrankieMasterContractTableViewCell *)configureCell:(FrankieMasterContractTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Job *job = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    if (job.title != nil)
        cell.title.text = job.title;
    
    NSArray *steps = job.steps;
    ProjectStep *nextStep = steps.firstObject;
    if (nextStep.name != nil) {
        cell.nextStepName.text = [NSString stringWithFormat:@"Next step: %@", nextStep.name];
    }
    if (nextStep.dueDate != nil) {
        double timeSinceDueDateInSeconds = [nextStep.dueDate timeIntervalSinceNow];
        int numberOfDays;
        if (timeSinceDueDateInSeconds / 86400 >= 0) {
            numberOfDays = floor(timeSinceDueDateInSeconds / 86400);
        }
        else {
            numberOfDays = ceil(timeSinceDueDateInSeconds / 86400);
        }
        
        if (numberOfDays > 0) {
            if (numberOfDays == 1)
                cell.nextStepDueDate.text = @"Due tomorrow";
            else
                cell.nextStepDueDate.text = [NSString stringWithFormat:@"Due in %d days", numberOfDays];
        }
        else if (numberOfDays == 0) {
            cell.nextStepDueDate.text = @"Due Today";
        }
        else {
            numberOfDays = abs(numberOfDays);
            if (numberOfDays == 1)
                cell.nextStepDueDate.text = @"Due yesterday";
            else
                cell.nextStepDueDate.text = [NSString stringWithFormat:@"Due %d days ago", numberOfDays];
        }
    }
    
    
    if (job.picture != nil) {
        UIImage *image = [UIImage imageWithData:job.picture];
        cell.picture.image = image;
    }
    else {
        cell.picture.image = [UIImage imageNamed:@"image-upload-icon-small"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
   [self.navigationController pushViewController:detailContractVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 87;
}

#pragma mark - UIImagePickerController delegate methods

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    
}

@end
