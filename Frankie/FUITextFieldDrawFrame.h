//
//  FUITextFieldDrawFrame.h
//  Frankie
//
//  Created by Benjamin Martin on 3/31/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FUITextField.h"
#import <FlatUIKit/FlatUIKit.h>

IB_DESIGNABLE
@interface FUITextFieldDrawFrame : FUITextField
@property (nonatomic) IBInspectable UIEdgeInsets edgeInsets;
@property (nonatomic) IBInspectable UIColor *textFieldColor;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadius;

@end
