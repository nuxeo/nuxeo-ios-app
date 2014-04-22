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

#import <NuxeoSDK/NUXTokenAuthenticator.h>

#import "NuxeoSettingsManager.h"

@implementation WelcomeViewController

#pragma mark -
#pragma mark WelcomeViewController
#pragma mark -

- (void) addHeaderButtonBar:(UIView *) navBarCustomView
{
    // no header button bar
}


#pragma mark -
#pragma mark UIViewControllerLifeCycle
#pragma mark -

- (void)viewDidLoad
{	
	[super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:USER_HOST_URL] != nil)
        self.hostURL.text = [[NSUserDefaults standardUserDefaults] valueForKey:USER_HOST_URL];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:USER_USERNAME] != nil)
        self.username.text = [[NSUserDefaults standardUserDefaults] valueForKey:USER_USERNAME];
    
#ifdef DEBUG
    self.hostURL.text = kNuxeoSiteURL;
    self.username.text = kNuxeoUser;
    self.password.text = kNuxeoPassword;
#endif
    
    self.footerBarView.hidden = YES;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
//    Do not uncomment
//	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark Events
#pragma mark -

- (IBAction)onTouchLaunch:(id)sender
{
    APP_DELEGATE.browseAllEnable = NO;
    APP_DELEGATE.syncAllEnable = NO;
    
    // Authentication
    [[NuxeoSettingsManager instance] saveSetting:self.hostURL.text forKey:USER_HOST_URL];
    [[NuxeoSettingsManager instance] saveSetting:self.username.text forKey:USER_USERNAME];
    
    NUXTokenAuthenticator *auth = [[NUXTokenAuthenticator alloc] init];
    // Those fields are mandatory
    auth.applicationName = kNuxeoAppName;
    auth.permission = kNuxeoPermission;
    
    NUXSession *session = [NUXSession sharedSession];
    [session setUrl:[NSURL URLWithString:self.hostURL.text]];
    session.authenticator = auth;
    if ([auth softAuthentication] == NO)
    {
        NUXRequest *request = [session requestTokenAuthentication];
        // We use the request built-in basic authentication challenge
        request.username = self.username.text;
        request.password = self.password.text;
        
        // Beware, request execution is asychronously.
        [auth setTokenFromRequest:request withCompletionBlock:^(BOOL success)
         {
             // if success, token saved !
             if (success == YES)
             {
                 [((NuxeoDriveViewController *)self.presentingViewController) retrieveBusinessObjects];
                 [self dismissViewControllerAnimated:YES completion:^{
                 }];
             }
         }];
    }
    else
    {
        // Otherwise; you might be authenticated, but do not forget that a token could be revoked.
        [((NuxeoDriveViewController *)self.presentingViewController) retrieveBusinessObjects];
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }

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
