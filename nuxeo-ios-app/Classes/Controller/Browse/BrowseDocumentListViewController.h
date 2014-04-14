//
//  BrowseDocumentListViewController.h
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

#import <NuxeoSDK/NUXDocument.h>
#import <NuxeoSDK/NUXDocuments.h>
#import <NuxeoSDK/NUXHierarchy.h>

#import "NuxeoDriveViewController.h"
#import "NuxeoFormViewController.h"

#import "NuxeoLabel.h"

@class NUXDocument;

@interface BrowseDocumentListViewController : NuxeoDriveViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIView *_breadCrumbsView;
    
    NSMutableArray * documents;
}

#pragma mark - Properties
@property (nonatomic, retain) NSMutableArray * path;
@property (nonatomic, retain) NSString * context;
@property (nonatomic, retain) NUXDocument * currentDocument;
@property (nonatomic, retain) NUXHierarchy * currentHierarchy;

@property (nonatomic, retain) IBOutlet UITableView *documentsView;
@property (nonatomic, retain) IBOutlet UILabel *documentPath;

@end
