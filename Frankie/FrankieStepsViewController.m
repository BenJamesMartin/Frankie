//
//  FrankieStepsViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/6/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieStepsViewController.h"
#import "FrankieStepsTableViewCell.h"

#import "FrankieAddEditContractViewController.h"
#import "ProjectStep.h"

@interface FrankieStepsViewController ()

@end

@implementation FrankieStepsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStep)];
    
    self.steps = [NSMutableArray new];
//    self.isNavigatingFromStepDetail = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StepsCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(doneEditing)];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)doneEditing
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Only for navigating from and back to addEdit (parent) VC
// If navigating from addEdit (this VC was pushed), parent is defined
// If navigating back to addEdit (this VC was popped), parent is undefined
- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    // Navigating back to add contract VC
    if (!parent){
        // Set text of steps cell and set steps property in add contract VC only if a step had been created
        FrankieAddEditContractViewController *avc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        
        UILabel *label = [UILabel new];
        NSString *labelText = (self.steps.count == 1 ? @"Step" : @"Steps");
        label.text = [NSString stringWithFormat:@"%lu %@    ", self.steps.count, labelText];
        label.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
        label.textColor = [UIColor darkGrayColor];
        [label sizeToFit];
        avc.stepsCell.accessoryView = label;
        
        avc.steps = self.steps;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Navigating back to add/edit VC. Next time the view appears, we'll be navigating back from it, not the step detail VC.
//    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
//        self.isNavigatingFromStepDetail = NO;
//    }
//    // Navigating to step detail VC. Next time the view appears, we'll be navigating back from it. Use this to determine when to reload table data and immediately present the step detail if no steps have been created yet.
//    else {
//        self.isNavigatingFromStepDetail = YES;
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // If applicable, deselect the previously selected table view cell
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // If we're navigating back from the step detail, no step was created, and there are 0 steps in total, don't show this VC as it will simply be an empty table view. Navigate back to the add/edit VC.
//    if (self.isNavigatingFromStepDetail) {
//        if (self.steps.count == 0) {
//            [self.navigationController popViewControllerAnimated:NO];
//        }
//    }
//    // Else we're navigating from the add/edit VC. If no steps exist, go straight to the creation of a new step instead of showing an empty table view.
//    else {
//        if (self.steps.count == 0) {
//            if (self.steps.count == 0) {
//                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                FrankieStepsDetailViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieStepsDetailViewController"];
//                
//                [self.navigationController pushViewController:dvc animated:YES];
//            }
//        }
//    }
}

// If navigating from creating a new step, an object was added to model. Reload the table view.
// If navigating here for the first time, there is no data so reloading it will do nothing.
// Table views cannot be manipulated until the view has appeared, so this must be done here (not in viewWillAppear).
- (void)viewDidAppear:(BOOL)animated
{
//    if (self.isNavigatingFromStepDetail) {
        [self.tableView reloadData];
//    }
}

// Nav bar top-right add button
- (void)addStep
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FrankieStepsDetailViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieStepsDetailViewController"];
    [self.navigationController pushViewController:dvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.steps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell"];
    
    FrankieStepsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[FrankieStepsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ProjectStep *step = self.steps[indexPath.row];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MMMM dd, yyyy";
    
    cell.name.text = step.name;
    if (step.picture != nil) {
        cell.picture.image = step.picture;
    }
    else {
        cell.picture.image = [UIImage imageNamed:@"image-upload-icon-small"];
    }
    cell.dueDate.text = [formatter stringFromDate:step.dueDate];
        
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FrankieStepsDetailViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieStepsDetailViewController"];

    dvc.step = self.steps[indexPath.row];
    [self.navigationController pushViewController:dvc animated:YES];
}

// Allow deletion of steps by side swipe
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.steps removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
