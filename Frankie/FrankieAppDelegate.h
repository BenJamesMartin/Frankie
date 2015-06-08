//
//  FrankieAppDelegate.h
//  Frankie
//
//  Created by Benjamin Martin on 1/6/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <PPRevealSideViewController/PPRevealSideViewController.h>

#import "FrankieSettingsViewController.h"
#import "FrankieMasterProjectViewController.h"

@interface FrankieAppDelegate : UIResponder <UIApplicationDelegate, PPRevealSideViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UINavigationController *nc;
@property (strong, nonatomic) PPRevealSideViewController *rsvc;
@property (strong, nonatomic) FrankieSettingsViewController *settingsVC;
@property (strong, nonatomic) FrankieMasterProjectViewController *masterVC;

- (BOOL)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
