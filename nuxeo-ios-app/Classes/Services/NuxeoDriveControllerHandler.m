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

#import "NuxeoDriveRemoteServices.h"
#import "NuxeoDriveControllerHandler.h"

#import "HomeViewController.h"
#import "BrowseDocumentListViewController.h"
#import "BrowseOnDeviceViewController.h"
#import "PreviewDisplayViewController.h"

#import "NuxeoFormViewController.h"
#import "NUXDocumentInfoForm.h"
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
    HomeViewController *rvc = [[HomeViewController alloc] init];
    
    rvc.backButtonShown = YES;
    rvc.updateAllButtonShown = YES;
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [iController presentViewController:rvc animated:YES completion:NULL];
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
    BrowseDocumentListViewController *rvc = [[[BrowseDocumentListViewController alloc] init] autorelease];
    
    if ([options objectForKey:kParamKeyContext] != nil)
        rvc.context = [options objectForKey:kParamKeyContext];
    else if ([iController isKindOfClass:[BrowseDocumentListViewController class]])
        rvc.context = ((BrowseDocumentListViewController *)iController).context;
    
    if ([options objectForKey:kParamKeyHierarchy] != nil)
        rvc.currentHierarchy = ([options objectForKey:kParamKeyHierarchy] == [NSNull null]) ? nil : [options objectForKey:kParamKeyHierarchy];

    if ([options objectForKey:kParamKeyDocument] != nil)
        rvc.currentDocument = [options objectForKey:kParamKeyDocument];
    
    if ([options objectForKey:kParamKeyBreadCrumbs] != nil)
        rvc.breadCrumbs = [options objectForKey:kParamKeyBreadCrumbs];
    else if ([iController isKindOfClass:[BrowseDocumentListViewController class]])
        rvc.breadCrumbs = [[((BrowseDocumentListViewController *)iController).breadCrumbs mutableCopy] autorelease];

    rvc.backButtonShown = YES;
    rvc.updateAllButtonShown = YES;
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [iController presentViewController:rvc animated:YES completion:NULL];
}

- (void) pushPreviewControllerFrom:(UIViewController *)iController options:(NSDictionary *) options
{
    PreviewDisplayViewController *rvc = [[PreviewDisplayViewController alloc] init];

    if ([options objectForKey:kParamKeyDocument] != nil)
        rvc.currentDocument = [options objectForKey:kParamKeyDocument];

    rvc.footerHidden = YES;
    rvc.backButtonShown = YES;
    rvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [iController presentViewController:rvc animated:YES completion:NULL];
    [rvc release];
}

- (void) pushDetailDocumentInfoControllerFrom:(UIViewController *)iController options:(NSDictionary *)options
{
    NuxeoFormViewController *formViewController_ = [[[NuxeoFormViewController alloc] init] autorelease];
    
    if ([options objectForKey:kParamKeyDocument] == nil)
        return ;
    
    NUXDocument *document_ = [options objectForKey:kParamKeyDocument];
    NUXDocumentInfoForm *infoForm_ = [[[NUXDocumentInfoForm alloc] initWithNUXDocumment:document_] autorelease];

    formViewController_.form = infoForm_;
    formViewController_.formTitle = NuxeoLocalized(@"detail.document.title");
    
    iController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [iController presentViewController:formViewController_ animated:YES completion:NULL];
}

- (void) pushSettingsControllerFrom:(UIViewController *)iController options:(NSDictionary *)options
{
    NuxeoFormViewController *formViewController_ = [[[NuxeoFormViewController alloc] init] autorelease];
    formViewController_.form = [NuxeoSettingForm instance];
    formViewController_.formTitle = NuxeoLocalized(@"settings.title");
    
    iController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [iController presentViewController:formViewController_ animated:YES completion:NULL];
}

@end
