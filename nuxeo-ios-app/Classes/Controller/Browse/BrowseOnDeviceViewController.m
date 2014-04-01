//
//  BrowseOnDeviceViewController.m
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

#import "BrowseOnDeviceViewController.h"

#import <NuxeoSDK/NUXDocument.h>

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXHierarchy.h>
#import <NuxeoSDK/NUXHierarchyDB.h>
#import <NuxeoSDK/NUXBlobStore.h>
#import <NuxeoSDK/NUXTokenAuthenticator.h>
#import <NuxeoSDK/NUXJSONSerializer.h>

#import "NuxeoDriveRemoteServices.h"

#import "UIAlertView+Blocks.h"

#import "DirectoryViewCell.h"

#define kSynchroReuseIdentifierForCollection    @"SynchroFolder"
#define kBrowseReuseIdentifierForCollection     @"BrowseFolder"

@implementation BrowseOnDeviceViewController

#pragma mark -
#pragma mark BrowseOnDeviceViewController
#pragma mark -

- (void) retrieveBusinessObjects
{
    [super retrieveBusinessObjects];
    
    // All Synchronized content
    {
        [[NuxeoDriveRemoteServices instance] retrieveAllSynchronizePoints:^(id results)
        {
            synchronizedPoints = [results retain];
            
            [self.synchronizedFolders reloadData];
        }];
    }
}

- (void) synchronizeAllView
{
    if ([APP_DELEGATE isNetworkConnected] == NO)
    {
        
    }
    else
    {
        
    }
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
	
    UINib  *directoryCellNib = [UINib nibWithNibName:kXIBDirectoryCellView bundle:nil];
    [self.synchronizedFolders registerNib:directoryCellNib forCellWithReuseIdentifier:kSynchroReuseIdentifierForCollection];
    
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

#pragma mark -
#pragma mark Events
#pragma mark -


#pragma mark -
#pragma mark UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.synchronizedFolders])
    {
        return [[synchronizedPoints entries] count];
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.synchronizedFolders])
    {
        DirectoryViewCell * cell = (DirectoryViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kSynchroReuseIdentifierForCollection forIndexPath:indexPath];
        
        NUXDocument * currentDocument = [synchronizedPoints.entries objectAtIndex:indexPath.row];
        
        cell.picto.image = [UIImage imageNamed:@"ic_synchro_type_folder"];
        cell.title.text = currentDocument.title;
        
        return cell;
    }
    return nil;
}

#pragma mark -
#pragma mark UICollectionViewDelegate
#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.synchronizedFolders])
    {
        
    }
}



#pragma mark -
#pragma mark UIViewController
#pragma mark -

#pragma mark Basics

- (void)dealloc
{
    
    [synchronizedPoints release];
    [super dealloc];
}
@end
