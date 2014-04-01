//
//  NuxeoDriveControllerHandler.m
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

#import "NuxeoDriveControllerHandler.h"

#import "HomeViewController.h"

#import "BrowseDocumentListViewController.h"
#import "BrowseOnDeviceViewController.h"
#import "PreviewDisplayViewController.h"
#import "DetailDocumentInfoViewController.h"
#import "SettingsViewController.h"

#import "NuxeoDriveRemoteServices.h"

@implementation NuxeoDriveControllerHandler


+ (NuxeoDriveControllerHandler *) instance
{
    static dispatch_once_t pred = 0;
    __strong static NuxeoDriveControllerHandler * _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        // or some other init method
    });
    return _sharedObject;
}

- (void) pushHomeControllerFrom:(UIViewController *)iController options:(NSDictionary *) options
{
    HomeViewController *rvc = [[HomeViewController alloc] initWithNibName:kXIBHomeController bundle:nil];
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rvc.isUpdateAllButtonShown = YES;
    rvc.isBackButtonShown = YES;
    [iController presentViewController:rvc animated:YES completion:^{
        
    }];
    [rvc release];
}

- (void) pushBrowseOnDeviceControllerFrom:(UIViewController *)iController options:(NSDictionary *) options
{
    BrowseOnDeviceViewController *rvc = [[BrowseOnDeviceViewController alloc] initWithNibName:kXIBBrowseOnDeviceViewController bundle:nil];
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rvc.isBackButtonShown = YES;
    rvc.isUpdateAllButtonShown = YES;
    [iController presentViewController:rvc animated:YES completion:^{
        
    }];
    [rvc release];
}

- (void) pushDocumentsControllerFrom:(UIViewController *)iController options:(NSDictionary *) options
{
    BrowseDocumentListViewController *rvc = [[BrowseDocumentListViewController alloc] initWithNibName:kXIBBrowseDocumentListViewController bundle:nil];
    if ([options objectForKey:kParamKeyDocument] != nil)
    {
        rvc.currentDocument = [options objectForKey:kParamKeyDocument];
    }    
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rvc.isBackButtonShown = YES;
    rvc.isUpdateAllButtonShown = YES;
    [iController presentViewController:rvc animated:YES completion:^{
        
    }];
    [rvc release];
}

- (void) pushPreviewControllerFrom:(UIViewController *)iController options:(NSDictionary *) options
{
    PreviewDisplayViewController *rvc = [[PreviewDisplayViewController alloc] initWithNibName:kXIBPreviewDisplayViewController bundle:nil];
    if ([options objectForKey:kParamKeyDocument] != nil)
    {
        rvc.currentDocument = [options objectForKey:kParamKeyDocument];
    }
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rvc.isBackButtonShown = YES;
    rvc.isFooterHidden = YES;
    [iController presentViewController:rvc animated:YES completion:^{
        
    }];
    [rvc release];
}

- (void) pushDetailDocumentInfoControllerFrom:(UIViewController *)iController options:(NSDictionary *)options
{
    DetailDocumentInfoViewController * rvc = [[DetailDocumentInfoViewController alloc]initWithNibName:kXIBDetailDocumentInfoViewController bundle:nil];
    if ([options objectForKey:kParamKeyDocument] != nil)
    {
        rvc.currentDocument = [options objectForKey:kParamKeyDocument];
    }
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rvc.isHeaderHidden = YES;
    rvc.isBackButtonShown = YES;
    rvc.isFooterHidden = YES;
    
    [iController.view addSubview:rvc.view];
}



- (void) pushSettingsControllerFrom:(UIViewController *)iController options:(NSDictionary *)options
{
    SettingsViewController * rvc = [[SettingsViewController alloc]initWithNibName:kXIBSettingsViewController bundle:nil];
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rvc.isHeaderHidden = YES;
    rvc.isBackButtonShown = YES;
    rvc.isFooterHidden = YES;
    
    [iController.view addSubview:rvc.view];
}

@end
