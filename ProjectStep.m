//
//  ProjectStep.m
//  Frankie
//
//  Created by Benjamin Martin on 4/8/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "ProjectStep.h"

@implementation ProjectStep

- (id)init {
    self = [super init];
    
    // Initialize step name to to empty string, project date to one month from now, and image to new image
    if (self) {
        self.name = @"[Step Name]";
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setMonth:1];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        self.dueDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
        
        self.picture = [UIImage imageNamed:@"image-upload-icon-small"];
    }
    
    return self;
}


@end
