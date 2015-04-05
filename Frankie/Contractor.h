//
//  Contractor.h
//  Frankie
//
//  Created by Benjamin Martin on 4/5/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contractor : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * email;

@end
