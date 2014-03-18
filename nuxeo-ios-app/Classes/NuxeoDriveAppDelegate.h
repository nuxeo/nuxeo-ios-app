//
//  NuxeoDriveAppDelegate.h
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

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark NuxeoDriveAppDelegate

@interface NuxeoDriveAppDelegate  : UIResponder <UIApplicationDelegate>
{
    BOOL isNetworkConnected;
    BOOL isWifiConnected;
}
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) BOOL isNetworkConnected;
@property (nonatomic, readonly) BOOL isWifiConnected;


@property (nonatomic) BOOL syncAllEnable;
@property (nonatomic) BOOL browseAllEnable;
@property (nonatomic) float syncAllProgressStatus;

@end
