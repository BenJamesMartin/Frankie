//
//  Job.h
//  Frankie
//
//  Created by Benjamin Martin on 5/15/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Job : NSManagedObject

@property (nonatomic, retain) NSDate * dueDate;
@property (nonatomic, retain) NSString * nextStep;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * parseId;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * completed;

@end
