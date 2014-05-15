//
//  DetailViewController.h
//  TableViewTest
//
//  Created by Benjamin Martin on 1/10/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property int characterNumber;
@property (strong, nonatomic) NSString *characterName;

@property (strong, nonatomic) IBOutlet UIImageView *characterImage;

@end
