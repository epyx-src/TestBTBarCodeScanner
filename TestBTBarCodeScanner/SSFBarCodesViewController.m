//
//  SSFBarCodesViewController.m
//  TestBTBarCodeScanner
//
//  Created by Vincent Fournié on 14.01.15.
//  Copyright (c) 2015 SwatchGroup. All rights reserved.
//

#import "SSFBarCodesViewController.h"

#define DEFAULT_QUANTITY @"1"
#define ROW_HEIGHT 50

@interface SSFBarCodesViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *barCodeTextField;
@property (nonatomic, strong) IBOutlet UITextField *quantityTextField;

@property (nonatomic, strong) NSMutableArray *products;

@property (nonatomic, strong) UIView *inputAccessoryView;

@end

@implementation SSFBarCodesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _products = [NSMutableArray new];
    _inputAccessoryView = [[UIView alloc] initWithFrame:CGRectZero];

    self.barCodeTextField.clearsOnBeginEditing = YES;
    self.quantityTextField.text = DEFAULT_QUANTITY;
    self.quantityTextField.inputAccessoryView = self.inputAccessoryView;

    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = ROW_HEIGHT;

    self.title = @"BT scanner";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldBegan:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
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
}

#pragma mark - Notification

- (void)textFieldBegan:(NSNotification *)notif
{
    UITextField *textField = [notif object];

    if (textField == self.quantityTextField) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self forceKeyboard];
        });
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.barCodeTextField) {
        // Ensure that the field is not empty
        if (textField.text.length == 0) {
            return NO;
        }

        [self.barCodeTextField resignFirstResponder];
        [self.quantityTextField becomeFirstResponder];
    }
    else if (textField == self.quantityTextField) {
        NSInteger quantity = [textField.text integerValue];
        NSString *barCode = self.barCodeTextField.text;
        // Ensure that the quantity is >= 1 and that the barCode is not empty
        if (quantity < 1 || barCode.length == 0) {
            return NO;
        }

        NSString *product = [self lookupProductForBarCode:barCode];

        [self.products addObject:@{
            @"productName" : product,
            @"quantity" : @(quantity),
        }];

        [self.quantityTextField resignFirstResponder];
        [self.barCodeTextField becomeFirstResponder];

        self.quantityTextField.text = DEFAULT_QUANTITY;
        self.barCodeTextField.text = @"";

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
    cell.textLabel.text = product[@"productName"];
    cell.detailTextLabel.text = [product[@"quantity"] stringValue];
    cell.userInteractionEnabled = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - Private

- (NSString *)lookupProductForBarCode:(NSString *)barCode
{
    return barCode;
}

- (void)forceKeyboard
{
    self.inputAccessoryView.superview.frame = CGRectMake(0, 416, 1024, 352);
}

@end
