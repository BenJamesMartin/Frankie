//
//  FrankieClientInformationViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/5/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import <UITextField+Shake/UITextField+Shake.h>

#import "FrankieClientInformationViewController.h"
#import "FrankieAddEditContractViewController.h"
#import "FrankieProjectManager.h"

@interface FrankieClientInformationViewController ()

@end

@implementation FrankieClientInformationViewController


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.clientInformation = [NSMutableDictionary new];
    self.infoField = @[@"name", @"phone", @"email"];
    
    self.childTableView = (FrankieClientInformationTableViewController *)self.childViewControllers[0];
    self.childTableView.nameField.delegate = self;
    self.childTableView.phoneField.delegate = self;
    self.childTableView.emailField.delegate = self;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(doneEditing)];
    
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSMutableDictionary *clientInformation = [[FrankieProjectManager sharedManager] fetchClientInformation].mutableCopy;
    if (clientInformation) {
        self.clientInformation = clientInformation;
        self.childTableView.nameField.text = [self.clientInformation objectForKey:@"name"];
        self.childTableView.phoneField.text = [self.clientInformation objectForKey:@"phone"];
        self.childTableView.emailField.text = [self.clientInformation objectForKey:@"email"];
    }
}

// Save info
- (void)viewWillDisappear:(BOOL)animated
{
    self.clientInformation[@"name"] = self.childTableView.nameField.text;
    self.clientInformation[@"phone"] = self.childTableView.phoneField.text;
    self.clientInformation[@"email"] = self.childTableView.emailField.text;
    
    [[FrankieProjectManager sharedManager] saveClientInformation:self.clientInformation];
    
    FrankieAddEditContractViewController *avc = [self.navigationController.viewControllers lastObject];
    avc.clientInformation = self.clientInformation;
    
    if (self.clientInformation[@"name"] != nil && ![self.clientInformation[@"name"] isEqualToString:@""]) {
        // Modify table view cell in add contract VC associated with location VC
        NSIndexPath *tableSelection = [avc.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [avc.tableView cellForRowAtIndexPath:tableSelection];
        
        UILabel *label = [UILabel new];
        label.text = [NSString stringWithFormat:@"%@   ", self.clientInformation[@"name"]];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
        label.textColor = [UIColor darkGrayColor];
        [label sizeToFit];
        if (label.frame.size.width > 135) {
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, 135, label.frame.size.height);
        }
        cell.accessoryView = label;
    }
}


#pragma mark - Left navigation "Save" button

- (void)doneEditing
{
    // Check inputs
    if ([self inputsAreValid])
        [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Simple keyboard dismissal

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = [UIColor darkGrayColor];
}

// Action that occurs when return button is tapped
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// Format phone number
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // If color was set to red from invalid input, set it back to default dark gray
    textField.textColor = [UIColor darkGrayColor];
    
    if ([textField isEqual:self.childTableView.phoneField]) {
        
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        BOOL deleting = [newText length] < [textField.text length];
        
        NSString *strippedNumber = [newText stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [newText length])];
        NSUInteger digits = [strippedNumber length];
        
        if (digits > 10)
            strippedNumber = [strippedNumber substringToIndex:10];
        
        UITextRange *selectedRange = [textField selectedTextRange];
        NSInteger oldLength = [textField.text length];
        
        if (digits == 0)
            textField.text = @"";
        else if (digits < 3 || (digits == 3 && deleting))
            textField.text = [NSString stringWithFormat:@"(%@", strippedNumber];
        else if (digits < 6 || (digits == 6 && deleting))
            textField.text = [NSString stringWithFormat:@"(%@) %@", [strippedNumber substringToIndex:3], [strippedNumber substringFromIndex:3]];
        else
            textField.text = [NSString stringWithFormat:@"(%@) %@-%@", [strippedNumber substringToIndex:3], [strippedNumber substringWithRange:NSMakeRange(3, 3)], [strippedNumber substringFromIndex:6]];
        
        UITextPosition *newPosition = [textField positionFromPosition:selectedRange.start offset:[textField.text length] - oldLength];
        UITextRange *newRange = [textField textRangeFromPosition:newPosition toPosition:newPosition];
        [textField setSelectedTextRange:newRange];
        
        return NO;
    }
    
    return YES;
}


#pragma mark - Valid email checker

- (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - Validate phone and email fields when leaving VC

- (BOOL)inputsAreValid
{
    // Fine to leave field alone if its blank (text length of 0)
    // Length of 14 = 10 digits + 2 parentheses + 1 space + 1 dash
    if ((self.childTableView.phoneField.text.length == 14 || self.childTableView.phoneField.text.length == 0) &&  ([self NSStringIsValidEmail:self.childTableView.emailField.text] || self.childTableView.emailField.text.length == 0)) {
        return YES;
    }
    else {
        [self invalidateInput];
        return NO;
    }
}

// Shake input to indicate it is incomplete or not formatted correctly
- (void)invalidateInput
{
    // If the phone number entered is not complete (10 numbers and 2 dashes added automatically), shake text field and change text color to red
    if (self.childTableView.phoneField.text.length < 12 && self.childTableView.phoneField.text.length > 0) {
        [self.childTableView.phoneField shake:10 withDelta:5 speed:0.05 completion:^{
            self.childTableView.phoneField.textColor = [UIColor alizarinColor];
        }];
    }
    
    // If the email entered is not valid, shake text field and change text color to red
    if (![self NSStringIsValidEmail:self.childTableView.emailField.text] && self.childTableView.emailField.text.length > 0) {
        [self.childTableView.emailField shake:10 withDelta:5 speed:0.05 completion:^{
            self.childTableView.emailField.textColor = [UIColor alizarinColor];
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
