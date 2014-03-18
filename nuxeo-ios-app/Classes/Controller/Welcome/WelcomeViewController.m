//
//  WelcomeViewController.m
//  NuxeoDrive
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
 * 	Matthias Rouberol
 */

#import "WelcomeViewController.h"

@implementation WelcomeViewController

#pragma mark -
#pragma mark WelcomeViewController
#pragma mark -

- (void) addHeaderButtonBar:(UIView *) navBarCustomView
{
    // no header button bar
}

- (void)updateDisplay
{
	
}

#pragma mark -
#pragma mark UIViewControllerLifeCycle
#pragma mark -

/**
 * Called after the loadView call
 */
- (void)loadView
{
	[super loadView];
	
    [self headerBarView].hidden = YES;
    
}

/**
 * Called after the viewDidLoad call
 */
- (void)viewDidLoad
{	
	[super viewDidLoad];
    
    
}

/**
 * Called after the viewWillAppear call
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
}

#pragma mark -
#pragma mark Events
#pragma mark -

- (IBAction)onTouchLaunch:(id)sender
{
    APP_DELEGATE.browseAllEnable = NO;
    APP_DELEGATE.syncAllEnable = NO;
    
    [CONTROLLER_HANDLER pushHomeControllerFrom:self options:nil];
    
}



#pragma mark -
#pragma mark UIViewController
#pragma mark -

#pragma mark Basics

- (void)dealloc
{
    [_password release];
    [_username release];
    [_hostURL release];
    [_loginForm release];
    [super dealloc];
}

@end
