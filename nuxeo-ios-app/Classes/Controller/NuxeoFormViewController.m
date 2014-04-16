//
//  NuxeoFormViewController.m
//  nuxeo-ios-app
//
/* (C) Copyright 2013-2014 Nuxeo SA (http://nuxeo.com/) and contributors.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl-2.1.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * Contributors:
 * 	Julien Di Marco
 */

#import <FXForms/FXForms.h>

#import "NuxeoFormViewController.h"

#pragma mark - BaseCell Overide for design / style -

@interface FXFormBaseCell (NuxeoFormView)
- (void)setUp;
@end

@implementation FXFormBaseCell (NuxeoFormView)

- (void)setUp
{
    self.layer.cornerRadius = 2;
    self.clipsToBounds = YES;
}

@end

#pragma mark - Disable some more warnings -

// !!!: Help Remove warning for tableView:heightForHeaderInSection: l178~
@interface NSObject ()
- (NSObject *)sectionAtIndex:(NSUInteger)index;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSString *footer;
@end

#pragma mark - NuxeoFormViewController Private Attributes -

@interface NuxeoFormViewController ()
@property (nonatomic, retain) UIColor *backgroundColor;
@end

@implementation NuxeoFormViewController

#pragma mark - Initializers -

- (id)init
{
    if ((self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]))
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
    self.formTitle = @"Nuxeo Form";
    self.form = nil;
    
    self.formController = [[FXFormController alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"ReloadFxForm" object:nil];
}

- (void)handleNotification:(NSNotification*)note
{
    NSLog(@"Got notified: %@", note);

    [_formTableView reloadData];
}

#pragma mark - UIViewController Life Cycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _contentView.layer.cornerRadius = 6;
    _actionButton.layer.cornerRadius = 2;
    
    _formTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _formTableView.scrollEnabled = NO;
    
    _titleLabel.text = self.formTitle;
    [_titleLabel sizeToFit];
    _titleLabel.center = (CGPoint){_titleLabel.center.x, _titleView.center.y};
    
    self.formController.tableView = _formTableView;
    self.formController.delegate = self;

    self.formController.form = self.form;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _titleLabel.text = self.formTitle;
    [_titleLabel sizeToFit];
    
    [_formTableView reloadData];
    [_formTableView sizeToFit];
    
    _formContentView.autoresizesSubviews = NO;
    _contentView.frame = (CGRect){_contentView.frame.origin, (CGRectGetWidth(_formTableView.frame) + 40),
        (CGRectGetHeight(_titleView.frame) + 40 + CGRectGetHeight(_formTableView.frame))};
    _contentView.center = self.view.center;
    
    if (animated)
    {
        self.backgroundColor = self.view.backgroundColor;
        self.view.backgroundColor = [UIColor clearColor];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (animated && self.backgroundColor)
        [UIView animateWithDuration:0.1 animations:^{
            self.view.backgroundColor = self.backgroundColor;
        }];
}

#pragma mark - Setters -

- (void)setFormTitle:(NSString *)formTitle
{
    if (_formTitle == formTitle)
        return ;
    
    NuxeoReleaseAndNil(_formTitle);
    _formTitle = [[formTitle uppercaseString] retain];

    if (!_titleLabel)
        return ;
        
    _titleLabel.text = _formTitle;
    [_titleLabel sizeToFit];
}

- (void)setForm:(id<FXForm>)form
{
    if (_form == form)
        return ;
    
    NuxeoReleaseAndNil(_form);
    _form = [form retain];
    
    self.formController.form = _form;
    [_formTableView reloadData];
}

#pragma mark - Events -

- (void)onTapActionButton:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
}

#pragma mark - Delegates Implementations -
#pragma mark UITableView

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
    
    tableViewHeaderFooterView.backgroundView.backgroundColor = _contentView.backgroundColor;
    tableViewHeaderFooterView.contentView.backgroundColor = _contentView.backgroundColor;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return [[self.formController sectionAtIndex:section] footer] ? 10 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self.formController sectionAtIndex:section] header] ? 42 : 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
    tableViewHeaderFooterView.textLabel.font = [UIFont fontWithName:@"Avenir" size:16.0f];
    tableViewHeaderFooterView.textLabel.textColor = [UIColor colorWithRed:0.352 green:0.352 blue:0.371 alpha:1.000];
    
    tableViewHeaderFooterView.backgroundView.backgroundColor = _contentView.backgroundColor;
    tableViewHeaderFooterView.contentView.backgroundColor = _contentView.backgroundColor;
}

#pragma mark - Memory Management -

- (void)dealloc
{
    NuxeoReleaseAndNil(_contentView);
    NuxeoReleaseAndNil(_titleView);
    NuxeoReleaseAndNil(_formContentView);
    
    NuxeoReleaseAndNil(_titleLabel);
    NuxeoReleaseAndNil(_actionButton);
    
    NuxeoReleaseAndNil(_formTableView);
    
    self.backgroundColor = nil;
    self.formController = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
