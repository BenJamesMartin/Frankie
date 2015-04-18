//
//  FrankieAppDelegate.m
//  Frankie
//
//  Created by Benjamin Martin on 1/6/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Parse/Parse.h>

#import "FrankieAppDelegate.h"
#import "FrankieLoginViewController.h"
#import "FrankieSideMenuViewController.h"
#import "Job.h"

@interface FrankieAppDelegate ()

@end

@implementation FrankieAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"khSDDzBANcF6RXKWBojSeDOweONmVysgIjvs5ceW" clientKey:@"urVIj0DX37q8Vc79SBRrob5T4okhIusgu4qwt6Kq"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    // Initialize side menu with Storyboard's root navigation controller
    self.nc = [storyboard instantiateViewControllerWithIdentifier:@"NC"];
    self.rsvc = [[PPRevealSideViewController alloc] initWithRootViewController:self.nc];
    self.rsvc.view.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.0];
    self.rsvc.delegate = self;
    self.rsvc.panInteractionsWhenClosed = PPRevealSideInteractionNavigationBar;
    self.rsvc.options = PPRevealSideOptionsShowShadows;
    [self.rsvc setDirectionsToShowBounce:PPRevealSideDirectionLeft];
    self.window.rootViewController = self.rsvc;
    
    // Preload left hamburger menu
    FrankieSideMenuViewController *smvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieSideMenuViewController"];
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:smvc];
    [self.rsvc preloadViewController:n forSide:PPRevealSideDirectionLeft];
    
    [self initializeObservers];
    
    return YES;
}

- (void)initializeObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revealSideMenu) name:@"revealSideMenu" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToProfile) name:@"navigateToProfile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToProjects) name:@"navigateToProjects" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"logout" object:nil];
}

- (void)revealSideMenu
{
    [self.rsvc pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}

- (void)logout
{
    [PFUser logOutInBackground];
    [self.rsvc popViewControllerAnimated:NO];
    [self.nc popToRootViewControllerAnimated:YES];
}

- (void)navigateToProfile
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (self.settingsVC == nil) {
        self.settingsVC = [storyboard instantiateViewControllerWithIdentifier:@"FrankieSettingsViewController"];   
    }
    [self.rsvc popViewControllerAnimated:YES];
    if ([self.nc.viewControllers indexOfObject:self] == NSNotFound) {
        [self.nc popViewControllerAnimated:NO];
        [self.nc pushViewController:self.settingsVC animated:NO];
    }
}

- (void)navigateToProjects
{
    [self.rsvc popViewControllerAnimated:YES];
    if ([self.nc.viewControllers indexOfObject:self.masterVC] == NSNotFound) {
        [self.nc popViewControllerAnimated:NO];
        [self.nc pushViewController:self.masterVC animated:NO];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Frankie Model.sqlite"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
        [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
         nil];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
