//
//  FrankieProjectManager.h
//  Frankie
//
//  Created by Benjamin Martin on 6/3/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Project.h"

@interface FrankieProjectManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) Project *currentProject;

+ (FrankieProjectManager *)sharedManager;

// Load various attributes
- (NSDictionary *)fetchClientInformation;
- (CLPlacemark *)fetchLocation;
- (NSString *)fetchNotes;

// Save various attributes
- (void)saveClientInformation:(NSDictionary *)clientInformation;
- (void)saveLocation:(CLPlacemark *)location;
- (void)saveNotes:(NSString *)notes;

@end
