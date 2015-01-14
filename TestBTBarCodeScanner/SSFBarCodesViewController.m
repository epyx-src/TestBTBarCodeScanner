//
//  SSFBarCodesViewController.m
//  TestBTBarCodeScanner
//
//  Created by Vincent Fournié on 14.01.15.
//  Copyright (c) 2015 SwatchGroup. All rights reserved.
//

#import "SSFBarCodesViewController.h"

@interface SSFBarCodesViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSMutableArray *barCodes;

@end

@implementation SSFBarCodesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _barCodes = [NSMutableArray new];

    self.title = @"BT scanner";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.textField resignFirstResponder];
}

#pragma mark - Actions

- (void)doneButtonPressed
{
    [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.barCodes addObject:textField.text];
    [self.tableView reloadData];

    textField.text = nil;

    return YES;
}

#pragma mark - Table view data source / delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.barCodes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Bar codes";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SSFBarCodeCell" forIndexPath:indexPath];

    NSString *barCode = self.barCodes[indexPath.row];
    cell.textLabel.text = barCode;
    cell.userInteractionEnabled = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

@end
