//
//  FrankieProjectManager.m
//  Frankie
//
//  Created by Benjamin Martin on 6/3/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieProjectManager.h"
#import "FrankieAppDelegate.h"

@implementation FrankieProjectManager


#pragma mark - Create shared instance

+ (FrankieProjectManager *)sharedManager
{
    static FrankieProjectManager *sharedManager = nil;
    static dispatch_once_t p;
    
    dispatch_once(&p, ^{
        sharedManager = [[self alloc] init];
        [sharedManager initializeCoreData];
    });
    
    return sharedManager;
}


#pragma mark - Core Data initialization

- (void)initializeCoreData
{
    FrankieAppDelegate *delegate = (FrankieAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.managedObjectModel = [delegate managedObjectModel];
    self.managedObjectContext = [delegate managedObjectContext];
    self.persistentStoreCoordinator = [delegate persistentStoreCoordinator];
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


#pragma mark - Load various attributes

- (NSDictionary *)fetchClientInformation
{
    return self.currentProject.clientInformation;
}

- (CLPlacemark *)fetchLocation
{
    return self.currentProject.location;
}

- (NSString *)fetchNotes
{
    return self.currentProject.notes;
}


#pragma mark - Save various attributes

- (void)saveClientInformation:(NSDictionary *)clientInformation
{
    [self.currentProject setValue:clientInformation forKey:@"clientInformation"];
    [self saveContext];
}

- (void)saveLocation:(CLPlacemark *)location
{
    [self.currentProject setValue:location forKey:@"location"];
    [self saveContext];
}

- (void)saveNotes:(NSString *)notes
{
    [self.currentProject setValue:notes forKey:@"notes"];
    [self saveContext];
}



@end
