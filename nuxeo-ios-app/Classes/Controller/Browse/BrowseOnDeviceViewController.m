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

#define kPopupActionInfo                        0
#define kPopupActionRemoveFromDevice            1


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
    [super synchronizeAllView];
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
    
    // Hide cloud button
    [self.pinButton setHidden:YES];
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
        
        cell.indexPath = indexPath;
        cell.picto.image = [UIImage imageNamed:@"ic_synchro_type_folder"];
        cell.title.text = currentDocument.title;
        
        [cell loadWithActionPopoverTitles:@[@[@"ic_info_blue", NuxeoLocalized(@"browse.info.document")], @[@"ic_remove_from_device", NuxeoLocalized(@"browse.remove.from.device")]]];
        cell.delegate = self;
        
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
        NUXDocument * selectedDocument = [synchronizedPoints.entries objectAtIndex:indexPath.row];
        if ([selectedDocument isFolder] == YES)
        {
            NUXHierarchy * hierarchy = [[NuxeoDriveRemoteServices instance] getHierarchyWithName:selectedDocument.path];//[NUXHierarchy hierarchyWithName:selectedDocument.path];
            [CONTROLLER_HANDLER pushDocumentsControllerFrom:self options:@{kParamKeyDocument: selectedDocument, kParamKeyHierarchy : hierarchy, kParamKeyContext : kBrowseDocumentOffLine}];
        }
        else
        {
            [CONTROLLER_HANDLER pushPreviewControllerFrom:self options:@{kParamKeyDocument: selectedDocument, kParamKeyContext : kBrowseDocumentOffLine}];
        }
        
        
    }
}



#pragma mark - NuxeoActionPopoverDelegate

- (void)actionPopoverCaller:(id)caller clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath * selectedDocumentIndex = ((DirectoryViewCell *)caller).indexPath;
    NUXDocument * selectedDocument = [synchronizedPoints.entries objectAtIndex:selectedDocumentIndex.row];
    switch (buttonIndex)
    {
        case kPopupActionInfo:
        {
            [[NuxeoDriveControllerHandler instance] pushDetailDocumentInfoControllerFrom:self options:@{kParamKeyDocument:selectedDocument}];
        }
            break;
        case kPopupActionRemoveFromDevice:
        {
            [[NuxeoDriveRemoteServices instance] removeSynchronizePoint:selectedDocument.path completionBlock:^(id result) {
                [self retrieveBusinessObjects];
            }];
        }
            break;
            
        default:
            break;
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
