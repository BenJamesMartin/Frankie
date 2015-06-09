//
//  Project.h
//  Frankie
//
//  Created by Benjamin Martin on 6/9/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contractor, NSManagedObject;

@interface Project : NSManagedObject

@property (nonatomic, retain) id clientInformation;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * parseId;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *steps;
@property (nonatomic, retain) Contractor *contractor;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addStepsObject:(NSManagedObject *)value;
- (void)removeStepsObject:(NSManagedObject *)value;
- (void)addSteps:(NSSet *)values;
- (void)removeSteps:(NSSet *)values;

@end
