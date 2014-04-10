//
//  NuxeoPopoverViewController.m
//  nuxeo-ios-app
//
//  Created by Julien Di Marco on 10/04/14.
//  Copyright (c) 2014 Sabre. All rights reserved.
//

#import "NuxeoPopoverViewController.h"

@interface NuxeoPopoverViewController ()

@end

@implementation NuxeoPopoverViewController

#pragma mark - Initializers -

- (id)init
{
    if ((self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil]))
        [self setup];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
        [self setup];
    return self;
}

- (void)setup
{
    self.delegate = nil;
    self.parentPopover = nil;
    
    _stringArray = [@[@"Unpin from home", @"Info", @"Remove from device", @"Train your cat"] retain];
}

#pragma mark - UIViewcontroller LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableview.scrollEnabled = NO;
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [_tableview reloadData];
    
    [_tableview sizeToFit];
    
    self.view.frame = (CGRect){self.view.frame.origin, _tableview.frame.size};
    self.contentSizeForViewInPopover = self.view.frame.size;
}

#pragma mark - Delegates Implementations -
#pragma mark UITableViewDataSource

// Default number of section is 1 so section can be ignored
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _stringArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];

    cell.selected = NO;
    cell.highlighted = NO;
    cell.textLabel.text = _stringArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"ic_password~ipad"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionPopover:clickedButtonAtIndex:)])
        [self.delegate actionPopover:self.parentPopover clickedButtonAtIndex:indexPath.row];
    
    [self.parentPopover dismissPopoverAnimated:YES];
}

#pragma mark - Memory Management -

- (void)dealloc
{
    NuxeoReleaseAndNil(_tableview);
    NuxeoReleaseAndNil(_stringArray);
    
    self.delegate = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
