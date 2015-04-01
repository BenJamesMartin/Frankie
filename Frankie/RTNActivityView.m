//
//  RTNActivityView.m
//  Ruben Niculcea
//
//  Created by Ruben Niculcea on 2/2/14.
//  Copyright (c) 2014 Ruben Niculcea. All rights reserved.
//

#import "RTNActivityView.h"

@interface  RTNActivityView ()

@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation RTNActivityView

+ (instancetype)sharedInstance {
    static RTNActivityView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)show
{
    UIWindow *result = [[[UIApplication sharedApplication] windows] lastObject];
    __weak RTNActivityView *ref = [RTNActivityView sharedInstance];
    
    ref.frame = result.frame;
    ref.backgroundColor = [UIColor colorWithWhite:.667 alpha:.5];
    
    if (ref.indicator == nil)
        ref.indicator = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    ref.indicator.color = [UIColor grayColor]; // White, no gray!
    ref.indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
    ref.indicator.center = ref.center;
    [ref addSubview:ref.indicator];
    
    [ref.indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    
    [result addSubview:ref];
}

+ (void)hide
{
    __weak RTNActivityView *ref = [RTNActivityView sharedInstance];
    [ref.indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [ref removeFromSuperview];
}

@end
