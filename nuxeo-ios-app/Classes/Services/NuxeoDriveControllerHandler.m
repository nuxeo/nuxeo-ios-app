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

#import "NuxeoFormViewController.h"
#import "NuxeoSettingForm.h"

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
    rvc.updateAllButtonShown = YES;
    rvc.backButtonShown = YES;
    [iController presentViewController:rvc animated:YES completion:^{
        
    }];
    [rvc release];
}

- (void) pushBrowseOnDeviceControllerFrom:(UIViewController *)iController options:(NSDictionary *) options
{
    BrowseOnDeviceViewController *rvc = [[BrowseOnDeviceViewController alloc] initWithNibName:kXIBBrowseOnDeviceViewController bundle:nil];
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rvc.backButtonShown = YES;
    rvc.updateAllButtonShown = YES;
    [iController presentViewController:rvc animated:YES completion:^{
        
    }];
    [rvc release];
}

- (void) pushDocumentsControllerFrom:(UIViewController *)iController options:(NSDictionary *) options
{
    BrowseDocumentListViewController *rvc = [[BrowseDocumentListViewController alloc] initWithNibName:kXIBBrowseDocumentListViewController bundle:nil];
    if ([options objectForKey:kParamKeyContext] != nil)
    {
        rvc.context = [options objectForKey:kParamKeyContext];
    }
    else
    {
        if ([iController isKindOfClass:[BrowseDocumentListViewController class]])
        {
            rvc.context = ((BrowseDocumentListViewController *)iController).context;
        }
        else
        {
            rvc.context = kBrowseDocumentOnLine;
        }
    }
    if ([options objectForKey:kParamKeyHierarchy] != nil)
    {
        rvc.currentHierarchy = [options objectForKey:kParamKeyHierarchy];
    }
    if ([options objectForKey:kParamKeyDocument] != nil)
    {
        rvc.currentDocument = [options objectForKey:kParamKeyDocument];
        if ([iController isKindOfClass:[BrowseDocumentListViewController class]])
        {
            if (((BrowseDocumentListViewController *)iController).path == nil)
            {
                rvc.path = [NSMutableArray array];
            }
            else
            {
                rvc.path = [((BrowseDocumentListViewController *)iController).path mutableCopy];
            }
            [rvc.path addObject:rvc.currentDocument.title];
        }
    }
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    rvc.backButtonShown = YES;
    rvc.updateAllButtonShown = YES;
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
    rvc.backButtonShown = YES;
    rvc.footerHidden = YES;
    [iController presentViewController:rvc animated:YES completion:^{
        
    }];
    [rvc release];
}

- (void) pushDetailDocumentInfoControllerFrom:(UIViewController *)iController options:(NSDictionary *)options
{
    NuxeoFormViewController *formViewController_ = [[[NuxeoFormViewController alloc] init] autorelease];
    
    if ([options objectForKey:kParamKeyDocument] != nil)
        formViewController_.form = [options objectForKey:kParamKeyDocument];
    
    iController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [iController presentViewController:formViewController_ animated:YES completion:NULL];
}



- (void) pushSettingsControllerFrom:(UIViewController *)iController options:(NSDictionary *)options
{
    NuxeoFormViewController *formViewController_ = [[[NuxeoFormViewController alloc] init] autorelease];
    formViewController_.form = [NuxeoSettingForm instance];
    
    iController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [iController presentViewController:formViewController_ animated:YES completion:NULL];
}

@end
