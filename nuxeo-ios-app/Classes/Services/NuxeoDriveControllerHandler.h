//
//  NuxeoDriveControllerHandler.h
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

#define kParamKeyDocument             @"document"

@interface NuxeoDriveControllerHandler : NSObject

+ (NuxeoDriveControllerHandler *) instance;

// ================ Splash screen
- (void) pushHomeControllerFrom:(UIViewController *)iController options:(NSDictionary *) options;

// ================ Home screen
//- (void) pushBrowseAllDocumentControllerFrom:(UIViewController *)iController;
- (void) pushBrowseOnDeviceControllerFrom:(UIViewController *)iController options:(NSDictionary *) options;
- (void) pushDocumentsControllerFrom:(UIViewController *)iController options:(NSDictionary *) options;

// ================ Browse screen
- (void) pushPreviewControllerFrom:(UIViewController *)iController options:(NSDictionary *) options;

@end
