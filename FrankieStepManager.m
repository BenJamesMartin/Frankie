//
//  FrankieStepManager.m
//  Frankie
//
//  Created by Benjamin Martin on 6/9/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieStepManager.h"
#import "FrankieAppDelegate.h"

@implementation FrankieStepManager

#pragma mark - Create shared instance

+ (FrankieStepManager *)sharedManager
{
    static FrankieStepManager *sharedManager = nil;
    static dispatch_once_t p;
    
    dispatch_once(&p, ^{
        sharedManager = [[self alloc] init];
        [sharedManager initializeCoreData];
    });
    
    return sharedManager;
}

- (void)initializeCoreData
{
    FrankieAppDelegate *delegate = (FrankieAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.managedObjectModel = [delegate managedObjectModel];
    self.managedObjectContext = [delegate managedObjectContext];
    self.persistentStoreCoordinator = [delegate persistentStoreCoordinator];
}


#pragma mark - Create new step

- (Step *)newStep
{
    return (Step *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Step class]) inManagedObjectContext:self.managedObjectContext];
}

@end
