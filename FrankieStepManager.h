//
//  FrankieStepManager.h
//  Frankie
//
//  Created by Benjamin Martin on 6/9/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Step.h"

@interface FrankieStepManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (FrankieStepManager *)sharedManager;

- (Step *)newStep;

@end
