//
//  ProjectStep.m
//  Frankie
//
//  Created by Benjamin Martin on 4/8/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "ProjectStep.h"

@implementation ProjectStep

static NSString * const kPicture = @"Picture";
static NSString * const kName = @"Name";
static NSString * const kDueDate = @"DueDate";
static NSString * const kCompleted = @"Completed";
static NSString * const kCompletionDate = @"CompletionDate";

- (id)init {
    self = [super init];
    
    // Initialize step name to to empty string, project date to one month from now, and image to new image
    if (self) {
        self.name = @"[Step Name]";
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setMonth:1];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        self.dueDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    }
    
    return self;
}

- (BOOL)nameHasBeenSet
{
    if ([self.name isEqualToString:@"[Step Name]"])
        return NO;
    return YES;
}


#pragma mark - Encoding for Core Data

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self=[super init])) {
        self.picture = [decoder decodeObjectForKey:kPicture];
        self.name = [decoder decodeObjectForKey:kName];
        self.dueDate = [decoder decodeObjectForKey:kDueDate];
        self.completed = [[decoder decodeObjectForKey:kCompleted] boolValue];
        self.completionDate = [decoder decodeObjectForKey:kCompletionDate];
    }
    
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.picture forKey:kPicture];
    [encoder encodeObject:self.name forKey:kName];
    [encoder encodeObject:self.dueDate forKey:kDueDate];
    [encoder encodeObject:[NSNumber numberWithBool:self.completed] forKey:kCompleted];
    [encoder encodeObject:self.completionDate forKey:kCompletionDate];
}


@end
