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

#import "FrankieMasterProjectViewController.h"
#import "FrankieMasterProjectTableViewCell.h"
#import "FrankieAddEditContractViewController.h"
#import "FrankieDetailProjectViewController.h"
#import "FrankieLoginViewController.h"
#import "FrankieSettingsViewController.h"
#import "FrankieAppDelegate.h"
#import "FrankieSideMenuViewController.h"
#import "FrankieProjectManager.h"
#import "Project.h"
#import "Step.h"
#import "SIAlertView.h"

@interface FrankieMasterProjectViewController ()

@end

@implementation FrankieMasterProjectViewController

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
//    [self syncParseWithCoreData];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FrankieMasterProjectTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    // Error handling when loading from fetched results controller
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:path animated:YES];
}

- (void)setNavigationBarAttributes
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 0.96;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger-icon"] landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(revealLeftMenu)];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
     target:self
     action:@selector(loadAddContractViewController)];
}

- (void)viewDidUnload
{
//    self.fetchedResultsController = nil;
}

- (void)revealLeftMenu
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"revealSideMenu" object:nil];
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
    // Because both the property name and the method name are 'fetchedResultsController', we must use _fetchedResultsController to access the property directly. self.fetchedResultsController will call the getter, resulting in an infinite loop. The exception is when setting the property (as we do below with "self.fetchedResultsController = aFetchedResultsController") or when sending a message to that instance (as we do below with "[fetchedResultsController performFetch:]").
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:NSStringFromClass([Project class])
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

#pragma mark - Fetched results controller delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
//    _fetchedResultsController = nil;
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
            [self configureCell:(FrankieMasterProjectTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            [self.tableView cellForRowAtIndexPath:indexPath];
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

- (void)syncParseWithCoreData
{
    NSError *error;
    NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:NSStringFromClass([Project class])
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
            for (Project *project in fetchedObjects) {
                // Add project to set
            }
            
            // User still can interact with app and store in Core Data when no connection
            // Use Core Data as the true data source
            // Add objects to Parse that exist in CD but not Parse
            // Delete objects from Parse that don't exist in CD but do in Parse.
            
            for (PFObject *project in objects) {
                for (Project *job in fetchedObjects)
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
            for (Project *job in fetchedObjects)
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
                NSEntityDescription *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Project class]) inManagedObjectContext:context];
                
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
            for (Project *job in projectsToDelete) {
                [context deleteObject:job];
            }
            if ([(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]) {
            }
        }
    }];
}

- (void)loadAddContractViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    FrankieAddEditContractViewController *addContractVC = [storyboard instantiateViewControllerWithIdentifier:@"FrankieAddEditContractViewController"];
    [self.navigationController pushViewController:addContractVC animated:YES];
}

- (void)logOutUser
{
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *i in selectedRows)
    {
        if (![i isEqual:indexPath]) {
            [tableView deselectRowAtIndexPath:i animated:NO];
            [self.tableView cellForRowAtIndexPath:indexPath].accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-detail-disclosure"]];
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FrankieDetailProjectViewController *dpvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieDetailProjectViewController"];
    
    Project *project = [_fetchedResultsController objectAtIndexPath:indexPath];
    dpvc.project = project;
    
//    [[FrankieProjectManager sharedManager] setCurrentProject:project];
    [FrankieProjectManager sharedManager].currentProject = project;
    [self.navigationController pushViewController:dpvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 87;
}

// Allows deletion of cells/projects by side swiping on table view cell
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Action to perform when tapping delete button revealed upon side swiping cell
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Project *job = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        // Protect from trying to delete a parse object immediately after it was created.
        // This causes the program to crash with error "Can not do a comparison for query type: (null)"
//        if ([job.parseId isEqual:[NSNull null]] || job.parseId == nil) {
//            return;
//        }
        
//        PFQuery *postQuery = [PFQuery queryWithClassName:@"Project"];
//        [postQuery whereKey:@"objectId" equalTo:job.parseId];
//        [postQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//            if (!error) {
//                [object deleteEventually];
//            }
//        }];
        
        NSManagedObjectContext *context = [(FrankieAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Project class])];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", job.objectID];
        [request setPredicate:predicate];
        
        NSError *error;
        NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
        
        for (Project *job in fetchedObjects) {
            [context deleteObject:job];
        }
        [context save:&error];
//        _fetchedResultsController = nil;
//        [self.tableView reloadData];
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
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    FrankieMasterProjectTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[FrankieMasterProjectTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(FrankieMasterProjectTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Project *job = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    // Add custom detail disclosure indicator
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-detail-disclosure"] highlightedImage:[UIImage imageNamed:@"custom-detail-disclosure"]];
    
    // If the job title has been set and it has not been edited to a blank string
    if (job.title != nil && ![job.title isEqualToString:@""])
        cell.title.text = job.title;
    else
        cell.title.text = @"[Title]";
    
    if (job.picture != nil) {
        UIImage *image = [UIImage imageWithData:job.picture];
        cell.picture.image = image;
    }
    else {
        cell.picture.image = [UIImage imageNamed:@"image-upload-icon-small"];
    }
    
    NSArray *steps = job.steps;
    if (steps.count == 0) {
        cell.projectCompleteLabel.alpha = 0.0;
        cell.nextStepDueDate.alpha = 0.0;
        cell.lateStepIcon.alpha = 0.0;
        cell.nextStepName.alpha = 1.0;
        cell.nextStepName.text = @"No steps created yet.";
        return;
    }
    
    Step *nextStep;
    for (Step *step in steps) {
        if (!step.completed.boolValue) {
            nextStep = step;
            break;
        }
    }

    // If no incomplete steps were found, the project is complete
    if (nextStep == nil) {
        cell.projectCompleteLabel.alpha = 1.0;
        cell.lateStepIcon.alpha = 0.0;
        cell.nextStepName.alpha = 0.0;
        cell.nextStepDueDate.alpha = 0.0;
    }
    else {
        cell.projectCompleteLabel.alpha = 0.0;
        cell.nextStepName.alpha = 1.0;
        cell.nextStepDueDate.alpha = 1.0;
        
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
                if (numberOfDays == 1) {
                    cell.nextStepDueDate.text = @"DUE TOMORROW";
                    cell.lateStepIcon.alpha = 1.0;
                }
                else
                    cell.nextStepDueDate.text = [NSString stringWithFormat:@"DUE IN %d DAYS", numberOfDays];
            }
            else if (numberOfDays == 0) {
                cell.nextStepDueDate.text = @"DUE TODAY";
                cell.lateStepIcon.alpha = 1.0;
            }
            else {
                numberOfDays = abs(numberOfDays);
                cell.lateStepIcon.alpha = 1.0;
                if (numberOfDays == 1)
                    cell.nextStepDueDate.text = @"DUE YESTERDAY";
                else
                    cell.nextStepDueDate.text = [NSString stringWithFormat:@"DUE %d DAYS AGO", numberOfDays];
            }
        }
    }
}


#pragma mark - UIImagePickerController delegate methods

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    
}

@end
