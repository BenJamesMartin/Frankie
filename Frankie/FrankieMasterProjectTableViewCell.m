//
//  FrankieMasterProjectTableViewCell.m
//  Frankie
//
//  Created by Benjamin Martin on 4/13/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieMasterProjectTableViewCell.h"

@implementation FrankieMasterProjectTableViewCell

- (void)awakeFromNib
{
    self.picture.contentMode = UIViewContentModeScaleAspectFill;
    self.picture.clipsToBounds = YES;
    self.picture.layer.cornerRadius = 25.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"custom-detail-disclosure"] highlightedImage:[UIImage imageNamed:@"custom-detail-disclosure"]];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
}

@end
