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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.clientInformation = [NSMutableDictionary new];
    self.infoField = @[@"name", @"phone", @"email"];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(doneEditing)];
    
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)doneEditing
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

// Save info
- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    
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

- (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%lu", indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44; // Default height
}


#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = [UIColor darkGrayColor];
    
    if (textField.tag == 1)
        self.phoneNumberField = textField;
    
    if (textField.tag == 2)
        self.emailField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.phoneNumberField) {
        // If the phone number entered is not complete (10 numbers and 2 dashes added automatically), shake text field and change text color to red
        if (self.phoneNumberField.text.length < 12) {
            [self.phoneNumberField shake:10 withDelta:5 speed:0.05 completion:^{
                self.phoneNumberField.textColor = [UIColor alizarinColor];
            }];
            return;
        }
    }
    
    if (textField == self.emailField) {
        // If the email entered is not valid, shake text field and change text color to red
        if (![self NSStringIsValidEmail:textField.text]) {
            [self.emailField shake:10 withDelta:5 speed:0.05 completion:^{
                self.emailField.textColor = [UIColor alizarinColor];
            }];
            return;
        }
    }
    
    // If inputs are correct, set client information
    self.clientInformation[self.infoField[textField.tag]] = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Format phone number

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.phoneNumberField]) {
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

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    
//    if (textField.tag != 1)
//        return YES;
//    
//    int length = [self getLength:textField.text];
//    
//    if(length == 10)
//    {
//        if(range.length == 0)
//            return NO;
//    }
//    
//    if(length == 3)
//    {
//        NSString *num = [self formatNumber:textField.text];
//        textField.text = [NSString stringWithFormat:@"%@-",num];
//        if(range.length > 0)
//            textField.text = [NSString stringWithFormat:@"%@-",[num substringToIndex:3]];
//    }
//    else if(length == 6)
//    {
//        NSString *num = [self formatNumber:textField.text];
//        textField.text = [NSString stringWithFormat:@"%@-%@-",[num  substringToIndex:3],[num substringFromIndex:3]];
//        if(range.length > 0)
//            textField.text = [NSString stringWithFormat:@"%@-%@",[num substringToIndex:3],[num substringFromIndex:3]];
//    }
//    
//    return YES;
//}

- (NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    if (length > 10) {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    
    return mobileNumber;
}


- (int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    
    return length;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor colorWithRed:210/255.f green:210/255.f blue:210/255.f alpha:1.0];
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    view.backgroundColor = [UIColor colorWithRed:210/255.f green:210/255.f blue:210/255.f alpha:1.0];
    return view;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
