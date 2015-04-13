//
//  FrankieStepsViewController.m
//  Frankie
//
//  Created by Benjamin Martin on 4/6/15.
//  Copyright (c) 2015 Benjamin Martin. All rights reserved.
//

#import "FrankieStepsViewController.h"
#import "FrankieStepsTableViewCell.h"

#import "FrankieAddContractViewController.h"
#import "ProjectStep.h"

@interface FrankieStepsViewController ()

@end

@implementation FrankieStepsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStep)];
    
    self.steps = [NSMutableArray new];
    self.stepCount = 0;
    self.cellForDetailView = [NSMutableDictionary new];
    self.isNavigatingFromDetailView = NO;
    self.shouldAddStep = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StepsCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    // Navigating back to add contract VC
    if (!parent){
        // Set text of steps cell and set steps property in add contract VC only if a step had been created
        if (self.shouldAddStep) {
            FrankieAddContractViewController *avc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
            
            NSIndexPath *tableSelection = [avc.tableView indexPathForSelectedRow];
            UITableViewCell *cell = [avc.tableView cellForRowAtIndexPath:tableSelection];
            
            UILabel *label = [UILabel new];
            NSString *labelText = (self.stepCount == 1 ? @"Step" : @"Steps");
            label.text = [NSString stringWithFormat:@"%d %@    ", self.stepCount, labelText];
            label.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
            label.textColor = [UIColor darkGrayColor];
            [label sizeToFit];
            cell.accessoryView = label;
            
            avc.steps = self.steps;
            self.shouldAddStep = NO;
        }
    }
}

// If navigating from creating a new step, add new table cell entry and associate that VC with correct index path
- (void)viewDidAppear:(BOOL)animated
{
    if (self.isNavigatingFromDetailView && !self.wasEditingStep) {
        NSInteger rowCount = [self.tableView numberOfRowsInSection:0];
        int pathCount = (int)(rowCount == 0 ? 0 : rowCount);
        NSIndexPath *path = [NSIndexPath indexPathForRow:pathCount inSection:0];
        self.cellForDetailView[path.description] = self.currentDVC;
    
        self.stepCount++;
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    }
    self.wasEditingStep = NO;
    self.isNavigatingFromDetailView = NO;
}

// Nav bar top-right add button
- (void)addStep
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FrankieStepsDetailViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieStepsDetailViewController"];
    [self.navigationController pushViewController:dvc animated:YES];
    self.currentDVC = dvc;
    self.wasEditingStep = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.stepCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell"];
    
    FrankieStepsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[FrankieStepsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ProjectStep *step = [self.steps lastObject];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MMMM dd, yyyy";
    
    cell.picture.image = step.picture;
    cell.name.text = step.name;
    cell.dueDate.text = [formatter stringFromDate:step.dueDate];
        
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FrankieStepsTableViewCell *cell = (FrankieStepsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    FrankieStepsDetailViewController *dvc = self.cellForDetailView[indexPath.description];
    
    if (dvc == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        dvc = [storyboard instantiateViewControllerWithIdentifier:@"FrankieStepsDetailViewController"];
        self.cellForDetailView[cell.description] = dvc;
    }

    self.wasEditingStep = YES;
    [self.navigationController pushViewController:dvc animated:YES];
}

// Allow deletion of steps by side swipe
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.stepCount--;
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
