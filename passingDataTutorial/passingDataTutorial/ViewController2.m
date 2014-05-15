//
//  ViewController2.m
//  passingDataTutorial
//
//  Created by Benjamin Martin on 1/9/14.
//  Copyright (c) 2014 Benjamin Martin. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.textField2.delegate = self;
    
    self.displayLabel2.text = self.stringFromTextField1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appendAndPassToVC1:(id)sender {
    
    [self.delegate passItemBack:self didFinishWithItem:[self.displayLabel2.text stringByAppendingString:self.textField2.text]];
    
//    [self.delegate passItemBack:self didFinishWithItem:self.textField2.text];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

@end
