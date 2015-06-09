//
//  Step.m
//  Frankie
//
//  Created by Benjamin Martin on 6/9/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "Step.h"


@implementation Step

@dynamic thumbnail;
@dynamic picture;
@dynamic name;
@dynamic dueDate;
@dynamic completed;
@dynamic completionDate;

- (BOOL)nameHasBeenSet
{
    if ([self.name isEqualToString:@"[Step Name]"])
        return NO;
    return YES;
}


@end
