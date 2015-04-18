//
//  ProjectStep.h
//  Frankie
//
//  Created by Benjamin Martin on 4/8/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectStep : NSObject

- (BOOL)nameHasBeenSet;

@property (strong, nonatomic) UIImage *picture;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *dueDate;
@property (assign, nonatomic) BOOL completed;
@property (strong, nonatomic) NSDate *completionDate;

@end
