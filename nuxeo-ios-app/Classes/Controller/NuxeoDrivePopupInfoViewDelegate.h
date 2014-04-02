//
//  NuxeoDrivePopupActionViewDelegate.h
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
 * 	Matthias Rouberol
 */

#import <Foundation/Foundation.h>

@protocol NuxeoDrivePopupActionViewDelegate <NSObject>

// Fire when user touch on info button on collectionViewCell
- (void) onTouchInfoAtIndexPath:(NSIndexPath *)indexPath;
// Fire when user touch on unpin button
- (void) onTouchUnpinAtIndexPath:(NSIndexPath *)indexPath;
// Fire when user touch on info button on popup
- (void) onTouchInfoButtonAtIndexPath:(NSIndexPath *)indexPath;
// Fire when user touch on remove from device button
- (void) onTouchRemoveAtIndexPath:(NSIndexPath *)indexPath;


@end
