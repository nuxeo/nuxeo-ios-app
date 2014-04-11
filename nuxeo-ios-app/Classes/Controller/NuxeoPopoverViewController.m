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

- (id)initWithTitles:(NSArray *)titles
{
    if ((self = [self init]))
        self.titles = titles;
    return self;
}

- (void)setup
{
    self.delegate = nil;
    self.parentPopover = nil;
    self.caller = nil;
    
    self.titles = @[@"Unpin from home", @"Info", @"Remove from device", @"Train your cat"];
}

#pragma mark - UIViewcontroller LifeCycle -

- (void)viewDidLoad
{
    [super viewDidLoad];

    _tableview.scrollEnabled = NO;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];

    [_tableview reloadData];
    [_tableview sizeToFit];
    
    self.view.frame = (CGRect){self.view.frame.origin, _tableview.frame.size};
    self.contentSizeForViewInPopover = self.view.frame.size;
}

#pragma mark - Setters -

- (void)setTitles:(NSArray *)titles
{
    if (_titles == titles)
        return ;
    
    NuxeoReleaseAndNil(_titles);
    _titles = [titles retain];
    
    [_tableview reloadData];
    [_tableview sizeToFit];
    
    self.view.frame = (CGRect){self.view.frame.origin, _tableview.frame.size};
    self.contentSizeForViewInPopover = self.view.frame.size;
    self.parentPopover.popoverContentSize = self.contentSizeForViewInPopover;
}

#pragma mark - Delegates Implementations -
#pragma mark UITableViewDataSource

// Default number of section is 1 so section can be ignored
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    NSArray *actionArray_ = nil;
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];

    if ([self.titles[indexPath.row] isKindOfClass:[NSArray class]])
        actionArray_ = self.titles[indexPath.row];
    else
        actionArray_ = @[@"", self.titles[indexPath.row]];
    
    cell.selected = NO;
    cell.highlighted = NO;
    cell.textLabel.text = actionArray_[1];
    cell.imageView.image = [UIImage imageNamed:actionArray_[0]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionPopover:clickedButtonAtIndex:)])
        [self.delegate actionPopover:self.parentPopover clickedButtonAtIndex:indexPath.row];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionPopoverCaller:clickedButtonAtIndex:)])
        [self.delegate actionPopoverCaller:self.caller clickedButtonAtIndex:indexPath.row];
    
    [self.parentPopover dismissPopoverAnimated:YES];
}

#pragma mark - Memory Management -

- (void)dealloc
{
    NuxeoReleaseAndNil(_tableview);
    
    self.delegate = nil;
    self.parentPopover = nil;
    
    self.titles = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
