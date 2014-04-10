//
//  HomeViewController.h
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
#import "NuxeoDriveViewController.h"

#import "NuxeoDrivePopupInfoViewDelegate.h"
#import "NuxeoLabel.h"

@class NUXDocument;

@interface HomeViewController : NuxeoDriveViewController <UICollectionViewDataSource, UICollectionViewDelegate, NuxeoDrivePopupActionViewDelegate>
{
    NUXDocument * rootDocument;
    NSArray * synchronizedFolders;
    
    // for popup info mechanism
    NSIndexPath * selectedDocumentIndex;
}

#pragma mark - Properties
@property (retain, nonatomic) IBOutlet UICollectionView *browsingFolders;
@property (retain, nonatomic) IBOutlet UIView *popupActions;

#pragma mark - Events
- (IBAction)onTouchUnpin:(id)sender;
- (IBAction)onTouchInfo:(id)sender;
- (IBAction)onTouchRemoveFromDevice:(id)sender;

// Test
- (IBAction)onTouchTest:(id)sender;

@end
