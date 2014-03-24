//
//  HomeViewController.m
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

#import "HomeViewController.h"

#import <NuxeoSDK/NUXDocument.h>

#import <NuxeoSDK/NUXSession.h>
#import <NuxeoSDK/NUXSession+requests.h>
#import <NuxeoSDK/NUXHierarchy.h>
#import <NuxeoSDK/NUXHierarchyDB.h>
#import <NuxeoSDK/NUXBlobStore.h>
#import <NuxeoSDK/NUXTokenAuthenticator.h>

#import "NuxeoDriveRemoteServices.h"

#import "UIAlertView+Blocks.h"

#import "DirectoryViewCell.h"

#define kSynchroReuseIdentifierForCollection    @"SynchroFolder"
#define kBrowseReuseIdentifierForCollection     @"BrowseFolder"

@implementation HomeViewController

#pragma mark -
#pragma mark HomeViewController
#pragma mark -

- (void) retrieveBusinessObjects
{
    [super retrieveBusinessObjects];
    
    
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

- (void) activateHomeScreen
{
    APP_DELEGATE.syncAllEnable = YES;
    APP_DELEGATE.browseAllEnable = YES;
    
}

- (void) setupMainHierarchy
{
//    [[NuxeoDriveRemoteServices instance] setupAllHierarchy:^(id object) {
//        [self activateHomeScreen];
//    }];
}

- (void) loadMainHierarchy
{
    [self setupMainHierarchy];
    //[[NuxeoDriveRemoteServices instance] retrieveBrowseAllHierarchy:^(id object) {
        [self activateHomeScreen];
    //}];
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
    
    UINib  *folderCellNib = [UINib nibWithNibName:kXIBDirectoryCellView bundle:nil];
    [self.browsingFolders registerNib:folderCellNib forCellWithReuseIdentifier:kBrowseReuseIdentifierForCollection];
    
}

/**
 * Called after the viewDidLoad call
 */
- (void)viewDidLoad
{	
	[super viewDidLoad];
    
    if ([[NUXHierarchyDB shared] isHierarchyLoaded:[[NuxeoDriveRemoteServices instance] mainHierarchyName]])
    {
        if ([APP_DELEGATE isNetworkConnected] == YES)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertView showWithTitle:NuxeoLocalized(@"application.name")
                                   message:NuxeoLocalized(@"home.hierarchy.load.question")
                         cancelButtonTitle:NuxeoLocalized(@"button.no")
                         otherButtonTitles:@[NuxeoLocalized(@"button.yes")]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
                {
                                      switch (buttonIndex)
                    {
                                          case 0:
                                              [self setupMainHierarchy];
                                              [self activateHomeScreen];
                                              break;
                                          case 1:
                                              [self loadMainHierarchy];
                                              break;
                                              
                                          default:
                                              break;
                                      }
                                  }];
            });
        } else {
            [self setupMainHierarchy];
            [self activateHomeScreen];
        }
    }
    else {
        if ([APP_DELEGATE isNetworkConnected] == YES) {
            [self loadMainHierarchy];
        }
    }
    
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

- (void) goBack:(id)sender
{
    NUXSession * nuxSession = [NUXSession sharedSession];
    if (nuxSession.authenticator != nil)
    {
        [((NUXTokenAuthenticator *)nuxSession.authenticator) resetSettings];
        [self checkAuthentication];
    }
    
}


#pragma mark -
#pragma mark UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.synchronizedFolders])
    {
        return 6;
    }
    else if ([collectionView isEqual:self.browsingFolders])
    {
        return 1;
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.synchronizedFolders])
    {
        DirectoryViewCell * cell = (DirectoryViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kSynchroReuseIdentifierForCollection forIndexPath:indexPath];
        
        
        
        return cell;
    }
    else if ([collectionView isEqual:self.browsingFolders])
    {
        DirectoryViewCell * cell = (DirectoryViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kBrowseReuseIdentifierForCollection forIndexPath:indexPath];
        
        
        
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
    else if ([collectionView isEqual:self.browsingFolders])
    {
        // Browse into selected folder
        [[NuxeoDriveControllerHandler instance] pushDocumentsControllerFrom:self options:nil];
        
    }
}



#pragma mark -
#pragma mark UIViewController
#pragma mark -

#pragma mark Basics

- (void)dealloc
{
    
    [_synchronizedFolders release];
    [_browsingFolders release];
    [super dealloc];
}
@end
