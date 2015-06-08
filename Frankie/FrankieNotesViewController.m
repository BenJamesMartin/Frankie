//
//  FrankieNotesViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/8/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieNotesViewController.h"
#import "FrankieAddEditContractViewController.h"
#import "FrankieProjectManager.h"

@interface FrankieNotesViewController ()

@end

@implementation FrankieNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Padding
    self.notes.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    
    // Border
    self.notes.layer.borderWidth = 1.0;
    self.notes.layer.borderColor = [UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1.0].CGColor;
    
    // Rounded corners
    self.notes.layer.cornerRadius = 3.0;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(doneEditing)];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.notes becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.notes.text = [[FrankieProjectManager sharedManager] fetchNotes];
}

- (void)viewWillDisappear:(BOOL)animated
{
    FrankieAddEditContractViewController *avc = [self.navigationController.viewControllers lastObject];
    avc.notes = self.notes.text;
    [self.view endEditing:YES];
    
    [[FrankieProjectManager sharedManager] saveNotes:self.notes.text];
    
    // Add up to three words to notes table view cell in add contract VC
    if (self.notes.text.length > 0) {
        // Modify table view cell in add contract VC associated with location VC
        NSIndexPath *tableSelection = [avc.tableView indexPathForSelectedRow];
        UITableViewCell *cell = [avc.tableView cellForRowAtIndexPath:tableSelection];
        
        NSArray *words = [self.notes.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSMutableString *mutableNotes = [[NSMutableString alloc] initWithString:@""];
        
        for (int i = 0; i < words.count; i++) {
            [mutableNotes appendString:words[i]];
            if (i != words.count - 1)
                [mutableNotes appendString:@" "];
            if (i == 2)
                break;
        }
        [mutableNotes appendString:@"...   "];
        
        UILabel *label = [UILabel new];
        label.text = mutableNotes;
        label.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
        label.textColor = [UIColor darkGrayColor];
        [label sizeToFit];
        if (label.frame.size.width > 135) {
            label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, 135, label.frame.size.height);
        }
        cell.accessoryView = label;
    }

}

- (void)doneEditing
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    if ([textView.text isEqualToString:@"additional notes"]) {
//        textView.text = @"";
//        textView.textAlignment = NSTextAlignmentLeft;
//        textView.textColor = [UIColor colorWithRed:150/255.f green:150/255.f blue:160/255.f alpha:1.0];
//    }
//    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    if ([textView.text isEqualToString:@""]) {
//        textView.text = @"additional notes";
//        textView.textAlignment = NSTextAlignmentCenter;
//        textView.textColor = [UIColor colorWithRed:185/255.f green:185/255.f blue:185/255.f alpha:1.0];
//    }
//    [textView resignFirstResponder];
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
