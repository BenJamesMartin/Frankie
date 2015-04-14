//
//  FrankieMasterContractTableViewCell.m
//  Frankie
//
//  Created by Benjamin Martin on 4/13/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieMasterContractTableViewCell.h"

@implementation FrankieMasterContractTableViewCell

- (void)awakeFromNib
{
    self.picture.contentMode = UIViewContentModeScaleAspectFill;
    self.picture.clipsToBounds = YES;
    self.picture.layer.cornerRadius = 25.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
