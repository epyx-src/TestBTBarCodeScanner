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
@property (nonatomic, strong) IBOutlet UITextField *barCodeTextField;
@property (nonatomic, strong) IBOutlet UITextField *quantityTextField;

@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) NSString *barCode;

@end

@implementation SSFBarCodesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _products = [NSMutableArray new];

    self.quantityTextField.text = @"1";

    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.title = @"BT scanner";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.barCodeTextField resignFirstResponder];
    [self.quantityTextField resignFirstResponder];
}

#pragma mark - Actions

- (void)doneButtonPressed
{
    [self.barCodeTextField resignFirstResponder];
    [self.quantityTextField resignFirstResponder];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = YES;

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.barCodeTextField) {
        // Ensure that the field is not empty
        if (textField.text.length == 0) {
            return NO;
        }
        self.barCode = textField.text;

        [self.barCodeTextField resignFirstResponder];
        [self.quantityTextField becomeFirstResponder];
    }
    else if (textField == self.quantityTextField) {
        NSInteger quantity = [textField.text integerValue];
        // Ensure that the quantity is >= 1 and that the barCode is not empty
        if (quantity < 1 || self.barCode.length == 0) {
            return NO;
        }

        [self.quantityTextField resignFirstResponder];
        [self.barCodeTextField becomeFirstResponder];

        [self.products addObject:@{
            @"barCode" : self.barCode,
            @"quantity" : @(quantity),
        }];

        self.barCode = nil;
        self.quantityTextField.text = @"1";

        [self.tableView reloadData];
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.quantityTextField) {
        // Allow backspace
        if (!string.length) {
            return YES;
        }
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound) {
            return NO;
        }
    }

    return YES;
}

#pragma mark - Table view data source / delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.products count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Products";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SSFBarCodeCell" forIndexPath:indexPath];

    NSDictionary *product = self.products[indexPath.row];
    cell.textLabel.text = product[@"barCode"];
    cell.detailTextLabel.text = [product[@"quantity"] stringValue];
    cell.userInteractionEnabled = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

@end
