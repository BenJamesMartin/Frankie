//
//  FrankieNotesViewController.h
//  Frankie
//
//  Created by Benjamin Martin on 4/8/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrankieNotesViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *notes;

@end
